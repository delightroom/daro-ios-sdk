package so.daro.flutter

import android.app.Activity
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import droom.daro.core.adunit.DaroRewardedAdUnit
import droom.daro.loader.DaroRewardedAdLoader
import droom.daro.core.listener.DaroRewardedAdLoaderListener
import droom.daro.core.model.DaroRewardedAd
import droom.daro.core.listener.DaroRewardedAdListener
import droom.daro.core.model.DaroAdInfo
import droom.daro.core.model.DaroAdLoadError
import droom.daro.core.model.DaroAdDisplayFailError

class DaroRewardedAdManager : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private var activity: Activity? = null
    private var eventSink: EventChannel.EventSink? = null
    private val adLoaders = mutableMapOf<String, DaroRewardedAdLoader>()
    private val ads = mutableMapOf<String, DaroRewardedAd>()
    private val mainHandler = Handler(Looper.getMainLooper())

    fun setActivity(activity: Activity?) {
        this.activity = activity
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadAd" -> loadAd(call, result)
            "isAdReady" -> isAdReady(call, result)
            "showAd" -> showAd(call, result)
            "destroyAd" -> destroyAd(call, result)
            else -> result.notImplemented()
        }
    }

    private fun extractAdUnitId(call: MethodCall, result: MethodChannel.Result): String? {
        val adUnitId = call.argument<String>("adUnitId")
        if (adUnitId == null) {
            result.error("INVALID_ARGS", "Missing adUnitId", null)
            return null
        }
        return adUnitId
    }

    private fun loadAd(call: MethodCall, result: MethodChannel.Result) {
        val adUnitId = extractAdUnitId(call, result) ?: return

        val placement = call.argument<String>("placement") ?: ""
        val activity = this.activity

        if (activity == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        ads[adUnitId]?.destroy()
        ads.remove(adUnitId)
        adLoaders.remove(adUnitId)

        val adUnit = DaroRewardedAdUnit(
            key = adUnitId,
            placement = placement
        )

        val loader = DaroRewardedAdLoader(
            context = activity,
            adUnit = adUnit
        )
        adLoaders[adUnitId] = loader

        loader.setListener(createAdLoaderListener(adUnitId))
        loader.load()
        result.success(null)
    }

    private fun createAdLoaderListener(adUnitId: String): DaroRewardedAdLoaderListener {
        return object : DaroRewardedAdLoaderListener {
            override fun onAdLoadSuccess(ad: DaroRewardedAd, adInfo: DaroAdInfo) {
                ads[adUnitId] = ad
                ad.setListener(createAdListener(adUnitId))
                sendAdInfoEvent("onAdLoadSuccess", adUnitId, adInfo)
            }

            override fun onAdLoadFail(err: DaroAdLoadError) {
                sendAdLoadErrorEvent("onAdLoadFail", adUnitId, err)
            }
        }
    }

    private fun createAdListener(adUnitId: String): DaroRewardedAdListener {
        return object : DaroRewardedAdListener {
            override fun onShown(adInfo: DaroAdInfo) {
                sendAdInfoEvent("onAdShown", adUnitId, adInfo)
            }

            override fun onFailedToShow(adInfo: DaroAdInfo, error: DaroAdDisplayFailError) {
                sendAdDisplayErrorEvent("onAdFailedToShow", adUnitId, error)
            }

            override fun onDismiss(adInfo: DaroAdInfo) {
                ads[adUnitId]?.destroy()
                ads.remove(adUnitId)
                sendAdInfoEvent("onAdDismiss", adUnitId, adInfo)
            }

            override fun onEarnedReward(adInfo: DaroAdInfo, rewardItem: DaroRewardedAd.DaroRewardedItem) {
                sendRewardEvent("onEarnedReward", adUnitId, adInfo, rewardItem)
            }

            override fun onAdClicked(adInfo: DaroAdInfo) {
                sendAdInfoEvent("onAdClicked", adUnitId, adInfo)
            }

            override fun onAdImpression(adInfo: DaroAdInfo) {
                sendAdInfoEvent("onAdImpression", adUnitId, adInfo)
            }
        }
    }

    private fun isAdReady(call: MethodCall, result: MethodChannel.Result) {
        val adUnitId = extractAdUnitId(call, result) ?: return

        val ready = ads.containsKey(adUnitId)
        result.success(ready)
    }

    private fun showAd(call: MethodCall, result: MethodChannel.Result) {
        val adUnitId = extractAdUnitId(call, result) ?: return

        val ad = ads[adUnitId]
        if (ad == null) {
            result.error("AD_NOT_LOADED", "Ad not loaded", null)
            return
        }

        val activity = this.activity
        if (activity == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        ad.show(activity = activity)
        result.success(null)
    }

    private fun destroyAd(call: MethodCall, result: MethodChannel.Result) {
        val adUnitId = extractAdUnitId(call, result) ?: return

        ads[adUnitId]?.destroy()
        ads.remove(adUnitId)
        adLoaders.remove(adUnitId)
        result.success(null)
    }

    private fun adInfoToMap(adInfo: DaroAdInfo, adUnitId: String): Map<String, Any> {
        return mapOf(
            "adUnitId" to adUnitId
        )
    }

    private fun sendAdInfoEvent(eventType: String, adUnitId: String, adInfo: DaroAdInfo) {
        sendEvent(
            mapOf(
                "eventType" to eventType,
                "adUnitId" to adUnitId,
                "adInfo" to adInfoToMap(adInfo, adUnitId)
            )
        )
    }

    private fun sendRewardEvent(
        eventType: String,
        adUnitId: String,
        adInfo: DaroAdInfo,
        rewardItem: DaroRewardedAd.DaroRewardedItem
    ) {
        sendEvent(
            mapOf(
                "eventType" to eventType,
                "adUnitId" to adUnitId,
                "adInfo" to adInfoToMap(adInfo, adUnitId),
                "reward" to mapOf(
                    "amount" to rewardItem.amount,
                    "type" to rewardItem.type
                )
            )
        )
    }

    private fun sendAdLoadErrorEvent(eventType: String, adUnitId: String, error: DaroAdLoadError) {
        sendEvent(
            mapOf(
                "eventType" to eventType,
                "adUnitId" to adUnitId,
                "error" to mapOf(
                    "code" to error.code,
                    "message" to error.message,
                    "adUnitId" to adUnitId
                )
            )
        )
    }

    private fun sendAdDisplayErrorEvent(eventType: String, adUnitId: String, error: DaroAdDisplayFailError) {
        sendEvent(
            mapOf(
                "eventType" to eventType,
                "adUnitId" to adUnitId,
                "error" to mapOf(
                    "code" to -1,
                    "message" to error.message
                )
            )
        )
    }

    private fun sendEvent(event: Map<String, Any>) {
        mainHandler.post {
            eventSink?.success(event)
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        this.eventSink = null
    }
}
