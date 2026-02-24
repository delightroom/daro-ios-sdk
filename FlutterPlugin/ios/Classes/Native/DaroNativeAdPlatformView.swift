import Flutter
import Daro

class DaroNativeAdPlatformView: NSObject, FlutterPlatformView {
    private let containerView: UIView
    private var nativeAdView: DaroAdNativeView
    private let adId: Int
    private let channel: FlutterMethodChannel

    init(
        frame: CGRect,
        adId: Int,
        adUnitId: String,
        factory: DaroNativeAdFactory,
        channel: FlutterMethodChannel
    ) {
        self.containerView = UIView(frame: frame)
        self.containerView.backgroundColor = .clear
        self.adId = adId
        self.channel = channel

        let adUnit = DaroAdUnit(unitId: adUnitId)
        self.nativeAdView = factory.createNativeAdView(unit: adUnit)

        super.init()

        setupNativeAd()
    }

    func view() -> UIView {
        return containerView
    }

    private func setupNativeAd() {
        nativeAdView.listener.onAdLoadSuccess = { [weak self] (_: DaroAdUnit, _: DaroAdInfo?) in
            guard let self = self else { return }
            self.sendEvent(event: "onAdLoaded")
        }

        nativeAdView.listener.onAdLoadFail = { [weak self] (error: Error) in
            guard let self = self else { return }
            self.sendEvent(event: "onAdFailedToLoad", error: ["code": -1, "message": error.localizedDescription])
        }

        nativeAdView.listener.onAdClicked = { [weak self] (_: DaroAdInfo?) in
            guard let self = self else { return }
            self.sendEvent(event: "onAdClicked")
        }

        nativeAdView.listener.onAdImpression = { [weak self] (_: DaroAdInfo?) in
            guard let self = self else { return }
            self.sendEvent(event: "onAdImpression")
        }

        containerView.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nativeAdView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            nativeAdView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            nativeAdView.topAnchor.constraint(equalTo: containerView.topAnchor),
            nativeAdView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        nativeAdView.loadAd()
    }

    private func sendEvent(event: String, error: [String: Any]? = nil) {
        var arguments: [String: Any] = [
            "adId": adId,
            "event": event,
        ]

        if let error = error {
            arguments["error"] = error
        }

        channel.invokeMethod("onAdEvent", arguments: arguments)
    }
}
