import Flutter
import Daro

class DaroLineNativeAdPlatformView: NSObject, FlutterPlatformView {
    private let containerView: UIView
    private var lineNativeAdView: DaroAdLineBannerView
    private let adId: Int
    private let channel: FlutterMethodChannel

    init(
        frame: CGRect,
        adId: Int,
        adUnitId: String,
        configuration: DaroLineNativeAdConfiguration,
        channel: FlutterMethodChannel
    ) {
        self.containerView = UIView(frame: frame)
        self.containerView.backgroundColor = .clear
        self.adId = adId
        self.channel = channel

        let adUnit = DaroAdUnit(unitId: adUnitId)
        self.lineNativeAdView = DaroAdLineBannerView(unit: adUnit, autoLoad: false)
        self.lineNativeAdView.configuration = configuration

        super.init()

        setupLineNativeAd()
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
