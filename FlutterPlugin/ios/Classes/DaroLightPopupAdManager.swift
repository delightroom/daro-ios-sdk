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

        if let backgroundColor = args?["backgroundColor"] as? String {
            configuration.backgroundColor = colorFromHex(backgroundColor)
        }
        if let containerColor = args?["containerColor"] as? String {
            configuration.cardViewBackgroundColor = colorFromHex(containerColor)
        }
        if let adMarkLabelTextColor = args?["adMarkLabelTextColor"] as? String {
            configuration.adMarkLabelTextColor = colorFromHex(adMarkLabelTextColor)
        }
        if let adMarkLabelBackgroundColor = args?["adMarkLabelBackgroundColor"] as? String {
            configuration.adMarkLabelBackgroundColor = colorFromHex(adMarkLabelBackgroundColor)
        }
        if let titleColor = args?["titleColor"] as? String {
            configuration.titleTextColor = colorFromHex(titleColor)
        }
        if let bodyColor = args?["bodyColor"] as? String {
            configuration.bodyTextColor = colorFromHex(bodyColor)
        }
        if let ctaBackgroundColor = args?["ctaBackgroundColor"] as? String {
            configuration.ctaButtonBackgroundColor = colorFromHex(ctaBackgroundColor)
        }
        if let ctaTextColor = args?["ctaTextColor"] as? String {
            configuration.ctaButtonTextColor = colorFromHex(ctaTextColor)
        }
        if let closeButtonText = args?["closeButtonText"] as? String {
            configuration.closeButtonText = closeButtonText
        }
        if let closeButtonColor = args?["closeButtonColor"] as? String {
            configuration.closeButtonTextColor = colorFromHex(closeButtonColor)
        }

        return configuration
    }

    private func colorFromHex(_ hexString: String) -> UIColor {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)

        if hex.count == 8 {
            return UIColor(
                red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(rgbValue & 0x000000FF) / 255.0
            )
        } else {
            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        }
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
