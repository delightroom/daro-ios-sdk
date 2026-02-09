import Flutter
import UIKit
import Daro

class DaroLightPopupAdManager: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var adLoaders: [String: DaroLightPopupAdLoader] = [:]
    private var ads: [String: DaroLightPopupAd] = [:]
    private var configurations: [String: DaroLightPopupConfiguration] = [:]

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "loadAd":
            loadAd(call, result: result)
        case "isAdReady":
            isAdReady(call, result: result)
        case "showAd":
            showAd(call, result: result)
        case "destroyAd":
            destroyAd(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func extractAdUnitId(from call: FlutterMethodCall, result: @escaping FlutterResult) -> String? {
        guard let args = call.arguments as? [String: Any],
              let adUnitId = args["adUnitId"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing adUnitId", details: nil))
            return nil
        }
        return adUnitId
    }

    private func loadAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let adUnitId = extractAdUnitId(from: call, result: result) else { return }

        let args = call.arguments as? [String: Any]

        let configuration = buildConfiguration(from: args)
        configurations[adUnitId] = configuration

        let adUnit = DaroAdUnit(unitId: adUnitId)
        let loader = DaroLightPopupAdLoader(unit: adUnit)
        adLoaders[adUnitId] = loader

        loader.listener.onAdLoadSuccess = { [weak self] ad, adInfo in
            ad.configuration = configuration
            self?.ads[adUnitId] = ad
            self?.setupAdListener(adUnitId: adUnitId, ad: ad)
            self?.sendAdInfoEvent(eventType: "onAdLoadSuccess", adUnitId: adUnitId)
        }

        loader.listener.onAdLoadFail = { [weak self] error in
            self?.sendAdLoadErrorEvent(eventType: "onAdLoadFail", adUnitId: adUnitId, error: error)
        }

        loader.listener.onAdClicked = { [weak self] adInfo in
            self?.sendAdInfoEvent(eventType: "onAdClicked", adUnitId: adUnitId)
        }

        loader.listener.onAdImpression = { [weak self] adInfo in
            self?.sendAdInfoEvent(eventType: "onAdImpression", adUnitId: adUnitId)
        }

        loader.loadAd()
        result(nil)
    }

    private func buildConfiguration(from args: [String: Any]?) -> DaroLightPopupConfiguration {
        let configuration = DaroLightPopupConfiguration()

        if let map = args?["backgroundColor"] as? [String: Any], let color = colorFromMap(map) {
            configuration.backgroundColor = color
        }
        if let map = args?["containerColor"] as? [String: Any], let color = colorFromMap(map) {
            configuration.cardViewBackgroundColor = color
        }
        if let map = args?["adMarkLabelTextColor"] as? [String: Any], let color = colorFromMap(map) {
            configuration.adMarkLabelTextColor = color
        }
        if let map = args?["adMarkLabelBackgroundColor"] as? [String: Any], let color = colorFromMap(map) {
            configuration.adMarkLabelBackgroundColor = color
        }
        if let map = args?["titleColor"] as? [String: Any], let color = colorFromMap(map) {
            configuration.titleTextColor = color
        }
        if let map = args?["bodyColor"] as? [String: Any], let color = colorFromMap(map) {
            configuration.bodyTextColor = color
        }
        if let map = args?["ctaBackgroundColor"] as? [String: Any], let color = colorFromMap(map) {
            configuration.ctaButtonBackgroundColor = color
        }
        if let map = args?["ctaTextColor"] as? [String: Any], let color = colorFromMap(map) {
            configuration.ctaButtonTextColor = color
        }
        if let closeButtonText = args?["closeButtonText"] as? String {
            configuration.closeButtonText = closeButtonText
        }
        if let map = args?["closeButtonColor"] as? [String: Any], let color = colorFromMap(map) {
            configuration.closeButtonTextColor = color
        }

        return configuration
    }

    private func colorFromMap(_ map: [String: Any]) -> UIColor? {
        guard let r = map["r"] as? Int,
              let g = map["g"] as? Int,
              let b = map["b"] as? Int,
              let a = map["a"] as? Int else {
            return nil
        }
        return UIColor(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }

    private func setupAdListener(adUnitId: String, ad: DaroLightPopupAd) {
        ad.lightPopupAdListener.onShown = { [weak self] adInfo in
            self?.sendAdInfoEvent(eventType: "onAdShown", adUnitId: adUnitId)
        }

        ad.lightPopupAdListener.onFailedToShow = { [weak self] adInfo, error in
            self?.sendAdDisplayErrorEvent(eventType: "onAdFailedToShow", adUnitId: adUnitId, error: error)
        }

        ad.lightPopupAdListener.onDismiss = { [weak self] adInfo in
            self?.sendAdInfoEvent(eventType: "onAdDismiss", adUnitId: adUnitId)
        }
    }

    private func isAdReady(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let adUnitId = extractAdUnitId(from: call, result: result) else { return }

        let ready = ads[adUnitId] != nil
        result(ready)
    }

    private func showAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let adUnitId = extractAdUnitId(from: call, result: result) else { return }

        guard let ad = ads[adUnitId] else {
            result(FlutterError(code: "AD_NOT_LOADED", message: "Ad not loaded", details: nil))
            return
        }

        guard let viewController = UIApplication.shared.keyWindow?.rootViewController else {
            result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No view controller available", details: nil))
            return
        }

        var topViewController = viewController
        while let presented = topViewController.presentedViewController {
            topViewController = presented
        }

        ad.show(viewController: topViewController)
        result(nil)
    }

    private func destroyAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let adUnitId = extractAdUnitId(from: call, result: result) else { return }

        adLoaders.removeValue(forKey: adUnitId)
        ads.removeValue(forKey: adUnitId)
        configurations.removeValue(forKey: adUnitId)
        result(nil)
    }

    private func adInfoToMap(adUnitId: String) -> [String: Any] {
        return [
            "adUnitId": adUnitId,
            "format": "lightpopup"
        ]
    }

    private func sendAdInfoEvent(eventType: String, adUnitId: String) {
        sendEvent([
            "eventType": eventType,
            "adUnitId": adUnitId,
            "adInfo": adInfoToMap(adUnitId: adUnitId)
        ])
    }

    private func sendAdLoadErrorEvent(eventType: String, adUnitId: String, error: DaroError) {
        sendEvent([
            "eventType": eventType,
            "adUnitId": adUnitId,
            "error": [
                "code": error.code.rawValue,
                "message": error.message,
                "adUnitId": adUnitId
            ]
        ])
    }

    private func sendAdDisplayErrorEvent(eventType: String, adUnitId: String, error: DaroError) {
        sendEvent([
            "eventType": eventType,
            "adUnitId": adUnitId,
            "error": [
                "code": error.code.rawValue,
                "message": error.message
            ]
        ])
    }

    private func sendEvent(_ event: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.eventSink?(event)
        }
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
