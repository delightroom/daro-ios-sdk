import Flutter
import UIKit
import Daro

class DaroRewardedAdManager: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var adLoaders: [String: DaroRewardedAdLoader] = [:]
    private var ads: [String: DaroRewardedAd] = [:]

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
        let placement = args?["placement"] as? String

        let adUnit = DaroAdUnit(unitId: adUnitId)
        let loader = DaroRewardedAdLoader(unit: adUnit)
        adLoaders[adUnitId] = loader

        loader.listener.onAdLoadSuccess = { [weak self] ad, adInfo in
            self?.ads[adUnitId] = ad

            ad.rewardedAdListener.onShown = { [weak self] adInfo in
                self?.sendAdInfoEvent(eventType: "onAdShown", adUnitId: adUnitId)
            }

            ad.rewardedAdListener.onFailedToShow = { [weak self] adInfo, error in
                self?.sendAdDisplayErrorEvent(eventType: "onAdFailedToShow", adUnitId: adUnitId, error: error)
            }

            ad.rewardedAdListener.onDismiss = { [weak self] adInfo in
                self?.sendAdInfoEvent(eventType: "onAdDismiss", adUnitId: adUnitId)
            }

            ad.rewardedAdListener.onEarnedReward = { [weak self] adInfo, rewardItem in
                self?.sendRewardEvent(eventType: "onEarnedReward", adUnitId: adUnitId, rewardItem: rewardItem)
            }

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

        ad.show(viewController: nil)
        result(nil)
    }

    private func destroyAd(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let adUnitId = extractAdUnitId(from: call, result: result) else { return }

        adLoaders.removeValue(forKey: adUnitId)
        ads.removeValue(forKey: adUnitId)
        result(nil)
    }

    private func adInfoToMap(adUnitId: String) -> [String: Any] {
        return [
            "adUnitId": adUnitId,
            "format": "rewarded"
        ]
    }

    private func sendAdInfoEvent(eventType: String, adUnitId: String) {
        sendEvent([
            "eventType": eventType,
            "adUnitId": adUnitId,
            "adInfo": adInfoToMap(adUnitId: adUnitId)
        ])
    }

    private func sendRewardEvent(eventType: String, adUnitId: String, rewardItem: DaroRewardedItem?) {
        var event: [String: Any] = [
            "eventType": eventType,
            "adUnitId": adUnitId,
            "adInfo": adInfoToMap(adUnitId: adUnitId)
        ]

        if let reward = rewardItem {
            event["reward"] = [
                "amount": reward.amount,
                "type": reward.rewardType
            ]
        }

        sendEvent(event)
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
