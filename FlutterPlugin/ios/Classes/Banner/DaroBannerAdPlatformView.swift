import Flutter
import Daro

class DaroBannerAdPlatformView: NSObject, FlutterPlatformView {
    private let containerView: UIView
    private var bannerView: DaroAdBannerView
    private let adId: Int
    private let channel: FlutterMethodChannel

    init(
        frame: CGRect,
        adId: Int,
        adUnitId: String,
        bannerSize: DaroAdBannerSize,
        channel: FlutterMethodChannel
    ) {
        self.containerView = UIView(frame: frame)
        self.containerView.backgroundColor = .clear
        self.adId = adId
        self.channel = channel

        let adUnit = DaroAdUnit(unitId: adUnitId)
        self.bannerView = DaroAdBannerView(unit: adUnit, bannerSize: bannerSize, autoLoad: false)

        super.init()

        setupBannerAd()
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

        bannerView.loadAd()
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
