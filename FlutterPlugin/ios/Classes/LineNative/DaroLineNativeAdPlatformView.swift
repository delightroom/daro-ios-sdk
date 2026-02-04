import Flutter
import Daro

class DaroLineNativeAdPlatformView: NSObject, FlutterPlatformView {
    private let containerView: UIView
    private var lineNativeAdView: DaroAdLineBannerView
    private let messenger: FlutterBinaryMessenger
    private let viewId: Int64
    private let methodChannel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewId: Int64,
        adUnitId: String,
        configuration: DaroLineNativeAdConfiguration,
        messenger: FlutterBinaryMessenger
    ) {
        self.containerView = UIView(frame: frame)
        self.containerView.backgroundColor = .clear
        self.messenger = messenger
        self.viewId = viewId
        self.methodChannel = FlutterMethodChannel(
            name: "daro_flutter/line_native_ad",
            binaryMessenger: messenger
        )

        let adUnit = DaroAdUnit(unitId: adUnitId)
        self.lineNativeAdView = DaroAdLineBannerView(unit: adUnit, autoLoad: false)
        self.lineNativeAdView.configuration = configuration

        super.init()

        setupLineNativeAd()
        setupMethodChannel()
    }

    func view() -> UIView {
        return containerView
    }

    private func setupLineNativeAd() {
        lineNativeAdView.listener.onAdLoadSuccess = { [weak self] (_: DaroAdUnit, _: DaroAdInfo?) in
            guard let self = self else { return }
            self.sendEvent(event: "onAdLoaded")
        }

        lineNativeAdView.listener.onAdLoadFail = { [weak self] (error: Error) in
            guard let self = self else { return }
            self.sendEvent(event: "onAdFailedToLoad", error: ["code": -1, "message": error.localizedDescription])
        }

        lineNativeAdView.listener.onAdClicked = { [weak self] (_: DaroAdInfo?) in
            guard let self = self else { return }
            self.sendEvent(event: "onAdClicked")
        }

        lineNativeAdView.listener.onAdImpression = { [weak self] (_: DaroAdInfo?) in
            guard let self = self else { return }
            self.sendEvent(event: "onAdImpression")
        }

        containerView.addSubview(lineNativeAdView)
        lineNativeAdView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            lineNativeAdView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            lineNativeAdView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            lineNativeAdView.topAnchor.constraint(equalTo: containerView.topAnchor),
            lineNativeAdView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        lineNativeAdView.loadAd()
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
                self.lineNativeAdView.loadAd()
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
