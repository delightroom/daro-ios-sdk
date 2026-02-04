package so.daro.flutter

import android.app.Activity
import android.app.Application
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import droom.daro.core.adunit.DaroAppOpenAdUnit
import droom.daro.a.appopen.DaroAppOpenAdManager
import droom.daro.core.listener.DaroAppOpenAdLoaderListener
import droom.daro.core.model.DaroAppOpenAd
import droom.daro.core.listener.DaroAppOpenAdListener
import droom.daro.core.model.DaroAdInfo
import droom.daro.core.model.DaroAdLoadError
import droom.daro.core.model.DaroAdDisplayFailError

class DaroFlutterAppOpenAdManager : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private var application: Application? = null
    private var activity: Activity? = null
    private var eventSink: EventChannel.EventSink? = null
    private val adManagers = mutableMapOf<String, DaroAppOpenAdManager>()
    private val mainHandler = Handler(Looper.getMainLooper())

    fun setApplication(application: Application?) {
        this.application = application
    }

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
        val app = this.application

        if (app == null) {
            result.error("NO_APPLICATION", "Application not available", null)
            return
        }

        adManagers[adUnitId]?.destroy()
        adManagers.remove(adUnitId)

        val adUnit = DaroAppOpenAdUnit(
            key = adUnitId,
            placement = placement
        )

        val manager = DaroAppOpenAdManager.Builder(app)
            .setAdUnit(adUnit)
            .setAppOpenAdLoaderListener(createAdLoaderListener(adUnitId))
            .setAppOpenAdListener(createAdListener(adUnitId))
            .build()

        adManagers[adUnitId] = manager
        manager.loadAd()
        result.success(null)
    }

    private fun createAdLoaderListener(adUnitId: String): DaroAppOpenAdLoaderListener {
        return object : DaroAppOpenAdLoaderListener {
            override fun onAdLoadSuccess(ad: DaroAppOpenAd, adInfo: DaroAdInfo) {
                sendAdInfoEvent("onAdLoadSuccess", adUnitId, adInfo)
            }

            override fun onAdLoadFail(err: DaroAdLoadError) {
                sendAdLoadErrorEvent("onAdLoadFail", adUnitId, err)
            }
        }
    }

    private fun createAdListener(adUnitId: String): DaroAppOpenAdListener {
        return object : DaroAppOpenAdListener {
            override fun onShown(adInfo: DaroAdInfo) {
                sendAdInfoEvent("onAdShown", adUnitId, adInfo)
            }

            override fun onFailedToShow(adInfo: DaroAdInfo, error: DaroAdDisplayFailError) {
                sendAdDisplayErrorEvent("onAdFailedToShow", adUnitId, error)
            }

            override fun onDismiss(adInfo: DaroAdInfo) {
                sendAdInfoEvent("onAdDismiss", adUnitId, adInfo)
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

        val manager = adManagers[adUnitId]
        val ready = manager?.isAdAvailable() ?: false
        result.success(ready)
    }

    private fun showAd(call: MethodCall, result: MethodChannel.Result) {
        val adUnitId = extractAdUnitId(call, result) ?: return

        val manager = adManagers[adUnitId]
        if (manager == null) {
            result.error("AD_NOT_LOADED", "Ad not loaded", null)
            return
        }

        val activity = this.activity
        if (activity == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        manager.showIfAvailable(activity)
        result.success(null)
    }

    private fun destroyAd(call: MethodCall, result: MethodChannel.Result) {
        val adUnitId = extractAdUnitId(call, result) ?: return

        adManagers[adUnitId]?.destroy()
        adManagers.remove(adUnitId)
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
