package so.daro.flutter.native

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import droom.daro.core.adunit.DaroNativeAdUnit
import droom.daro.view.DaroNativeAdView
import droom.daro.core.model.DaroNativeAdBinder
import droom.daro.view.DaroAdViewListener
import droom.daro.core.model.DaroAdInfo
import droom.daro.core.model.DaroAdLoadError
import droom.daro.core.model.DaroViewAd

class DaroNativeAdPlatformView(
    context: Context,
    private val viewId: Int,
    private val adUnitId: String,
    private val factory: DaroNativeAdFactory,
    private val messenger: io.flutter.plugin.common.BinaryMessenger
) : PlatformView {

    private val containerView: FrameLayout = FrameLayout(context)
    private var nativeAdView: DaroNativeAdView? = null
    private val methodChannel: MethodChannel = MethodChannel(
        messenger,
        "daro_flutter/native_ad"
    )

    init {
        setupNativeAd(context)
        setupMethodChannel()
    }

    override fun getView(): View = containerView

    override fun dispose() {
        nativeAdView = null
    }

    private fun setupNativeAd(context: Context) {
        val customView = factory.createNativeAdView()
        val adBinder = factory.createAdBinder(customView)

        val adUnit = DaroNativeAdUnit(
            key = adUnitId,
            placement = ""
        )
        val nativeAdView = DaroNativeAdView(context, adUnit)
        this.nativeAdView = nativeAdView

        nativeAdView.setListener(object : DaroAdViewListener {
            override fun onAdLoadSuccess(ad: DaroViewAd, adInfo: DaroAdInfo) {
                sendEvent("onAdLoaded")
            }

            override fun onAdLoadFail(err: DaroAdLoadError) {
                sendEvent("onAdFailedToLoad", error = err.message ?: "Unknown error")
            }

            override fun onAdClicked(adInfo: DaroAdInfo) {
                sendEvent("onAdClicked")
            }

            override fun onAdImpression(adInfo: DaroAdInfo) {
                sendEvent("onAdImpression")
            }
        })

        nativeAdView.setAdBinder(adBinder)

        val layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        containerView.addView(nativeAdView, layoutParams)

        nativeAdView.loadAd()
    }

    private fun setupMethodChannel() {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "loadAd" -> {
                    val requestViewId = call.argument<Int>("viewId")
                    if (requestViewId != viewId) {
                        result.error("INVALID_ARGS", "Invalid viewId", null)
                        return@setMethodCallHandler
                    }
                    nativeAdView?.loadAd()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun sendEvent(event: String, error: String? = null) {
        val arguments = mutableMapOf<String, Any>(
            "viewId" to viewId,
            "event" to event
        )
        error?.let { arguments["error"] = it }

        methodChannel.invokeMethod("onAdEvent", arguments)
    }
}
