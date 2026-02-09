package so.daro.flutter

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import droom.daro.core.adunit.DaroLightPopupAdUnit
import droom.daro.core.listener.DaroLightPopupAdListener
import droom.daro.core.listener.DaroLightPopupAdLoaderListener
import droom.daro.core.model.DaroAdDisplayFailError
import droom.daro.core.model.DaroAdInfo
import droom.daro.core.model.DaroAdLoadError
import droom.daro.core.model.DaroLightPopupAd
import droom.daro.core.model.DaroLightPopupAdOptions
import droom.daro.loader.DaroLightPopupAdLoader

class DaroFlutterLightPopupAdManager : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private var context: Context? = null
    private var activity: Activity? = null
    private var eventSink: EventChannel.EventSink? = null
    private val adLoaders = mutableMapOf<String, DaroLightPopupAdLoader>()
    private val loadedAds = mutableMapOf<String, DaroLightPopupAd>()
    private val mainHandler = Handler(Looper.getMainLooper())

    fun setContext(context: Context?) {
        this.context = context
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
        val ctx = this.context

        if (ctx == null) {
            result.error("NO_CONTEXT", "Context not available", null)
            return
        }

        adLoaders[adUnitId]?.let {
            loadedAds[adUnitId]?.destroy()
            loadedAds.remove(adUnitId)
        }
        adLoaders.remove(adUnitId)

        val options = buildOptions(call)
        val adUnit = DaroLightPopupAdUnit(
            key = adUnitId,
            placement = placement,
            options = options
        )

        val loader = DaroLightPopupAdLoader(ctx, adUnit)
        loader.setListener(object : DaroLightPopupAdLoaderListener {
            override fun onAdLoadSuccess(ad: DaroLightPopupAd, adInfo: DaroAdInfo) {
                loadedAds[adUnitId] = ad
                setupAdListener(adUnitId, ad)
                sendAdInfoEvent("onAdLoadSuccess", adUnitId, adInfo)
            }

            override fun onAdLoadFail(err: DaroAdLoadError) {
                sendAdLoadErrorEvent("onAdLoadFail", adUnitId, err)
            }
        })

        adLoaders[adUnitId] = loader
        loader.load()
        result.success(null)
    }

    private fun buildOptions(call: MethodCall): DaroLightPopupAdOptions {
        val defaults = DaroLightPopupAdOptions()

        return DaroLightPopupAdOptions(
            backgroundColor = parseColorFromMap(call.argument<Map<*, *>>("backgroundColor")) ?: defaults.backgroundColor,
            containerColor = parseColorFromMap(call.argument<Map<*, *>>("containerColor")) ?: defaults.containerColor,
            adMarkLabelTextColor = parseColorFromMap(call.argument<Map<*, *>>("adMarkLabelTextColor")) ?: defaults.adMarkLabelTextColor,
            adMarkLabelBackgroundColor = parseColorFromMap(call.argument<Map<*, *>>("adMarkLabelBackgroundColor")) ?: defaults.adMarkLabelBackgroundColor,
            titleColor = parseColorFromMap(call.argument<Map<*, *>>("titleColor")) ?: defaults.titleColor,
            bodyColor = parseColorFromMap(call.argument<Map<*, *>>("bodyColor")) ?: defaults.bodyColor,
            ctaBackgroundColor = parseColorFromMap(call.argument<Map<*, *>>("ctaBackgroundColor")) ?: defaults.ctaBackgroundColor,
            ctaTextColor = parseColorFromMap(call.argument<Map<*, *>>("ctaTextColor")) ?: defaults.ctaTextColor,
            closeButtonText = call.argument<String>("closeButtonText") ?: defaults.closeButtonText,
            closeButtonColor = parseColorFromMap(call.argument<Map<*, *>>("closeButtonColor")) ?: defaults.closeButtonColor,
        )
    }

    private fun parseColorFromMap(map: Map<*, *>?): Int? {
        if (map == null) return null
        val r = (map["r"] as? Number)?.toInt() ?: return null
        val g = (map["g"] as? Number)?.toInt() ?: return null
        val b = (map["b"] as? Number)?.toInt() ?: return null
        val a = (map["a"] as? Number)?.toInt() ?: return null
        return Color.argb(a, r, g, b)
    }

    private fun setupAdListener(adUnitId: String, ad: DaroLightPopupAd) {
        ad.setListener(object : DaroLightPopupAdListener {
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
        })
    }

    private fun isAdReady(call: MethodCall, result: MethodChannel.Result) {
        val adUnitId = extractAdUnitId(call, result) ?: return
        val ready = loadedAds[adUnitId] != null
        result.success(ready)
    }

    private fun showAd(call: MethodCall, result: MethodChannel.Result) {
        val adUnitId = extractAdUnitId(call, result) ?: return

        val ad = loadedAds[adUnitId]
        if (ad == null) {
            result.error("AD_NOT_LOADED", "Ad not loaded", null)
            return
        }

        val activity = this.activity
        if (activity == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }

        ad.show(activity)
        result.success(null)
    }

    private fun destroyAd(call: MethodCall, result: MethodChannel.Result) {
        val adUnitId = extractAdUnitId(call, result) ?: return

        loadedAds[adUnitId]?.destroy()
        loadedAds.remove(adUnitId)
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
