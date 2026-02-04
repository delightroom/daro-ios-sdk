import Flutter
import Daro

class DaroBannerAdPlatformView: NSObject, FlutterPlatformView {
    private let containerView: UIView
    private var bannerView: DaroAdBannerView
    private let messenger: FlutterBinaryMessenger
    private let viewId: Int64
    private let methodChannel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewId: Int64,
        adUnitId: String,
        bannerSize: DaroAdBannerSize,
        messenger: FlutterBinaryMessenger
    ) {
        self.containerView = UIView(frame: frame)
        self.containerView.backgroundColor = .clear
        self.messenger = messenger
        self.viewId = viewId
        self.methodChannel = FlutterMethodChannel(
            name: "daro_flutter/banner_ad",
            binaryMessenger: messenger
        )

        let adUnit = DaroAdUnit(unitId: adUnitId)
        self.bannerView = DaroAdBannerView(unit: adUnit, bannerSize: bannerSize)

        super.init()

        setupBannerAd()
        setupMethodChannel()
    }

    func view() -> UIView {
        return containerView
    }

    private func setupBannerAd() {
        bannerView.listener.onAdLoadSuccess = { [weak self] (_: DaroAdUnit, _: DaroAdInfo?) in
            guard let self = self else { return }
            self.sendEvent(event: "onAdLoaded")
        }

        bannerView.listener.onAdLoadFail = { [weak self] (error: Error) in
            guard let self = self else { return }
            self.sendEvent(event: "onAdFailedToLoad", error: ["code": -1, "message": error.localizedDescription])
        }

        bannerView.listener.onAdClicked = { [weak self] (_: DaroAdInfo?) in
            guard let self = self else { return }
            self.sendEvent(event: "onAdClicked")
        }

        bannerView.listener.onAdImpression = { [weak self] (_: DaroAdInfo?) in
            guard let self = self else { return }
            self.sendEvent(event: "onAdImpression")
        }

        containerView.addSubview(bannerView)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bannerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            bannerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }

    private func setupMethodChannel() {
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else {
                result(FlutterError(code: "UNAVAILABLE", message: "View disposed", details: nil))
                return
            }

            switch call.method {
            case "loadAd":
                guard let args = call.arguments as? [String: Any],
                      let requestViewId = args["viewId"] as? Int64,
                      requestViewId == self.viewId else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Invalid viewId", details: nil))
                    return
                }
                self.bannerView.loadAd()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func sendEvent(event: String, error: [String: Any]? = nil) {
        var arguments: [String: Any] = [
            "viewId": viewId,
            "event": event,
        ]

        if let error = error {
            arguments["error"] = error
        }

        methodChannel.invokeMethod("onAdEvent", arguments: arguments)
    }
}
