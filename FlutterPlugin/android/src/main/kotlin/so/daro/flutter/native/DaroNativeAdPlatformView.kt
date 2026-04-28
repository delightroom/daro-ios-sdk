package so.daro.flutter.native

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import droom.daro.core.adunit.DaroNativeAdUnit
import droom.daro.view.DaroNativeAdView
import droom.daro.core.model.DaroNativeAdBinder
import droom.daro.core.model.DaroNativeAdChoicePlacement
import droom.daro.view.DaroAdViewListener
import droom.daro.core.model.DaroAdInfo
import droom.daro.core.model.DaroAdLoadError
import droom.daro.core.model.DaroViewAd

class DaroNativeAdPlatformView(
    context: Context,
    private val adId: Int,
    private val adUnitId: String,
    private val factory: DaroNativeAdFactory,
    private val adChoicePlacement: DaroNativeAdChoicePlacement,
    private val channel: MethodChannel
) : PlatformView {

    private val containerView: FrameLayout = FrameLayout(context)
    private var nativeAdView: DaroNativeAdView? = null

    init {
        setupNativeAd(context)
    }

    override fun getView(): View = containerView

    override fun dispose() {
        nativeAdView?.destroy()
        nativeAdView = null
    }

    private fun setupNativeAd(context: Context) {
        val customView = factory.createNativeAdView()
        val adBinder = factory.createAdBinder(customView, adChoicePlacement)

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
                sendEvent("onAdFailedToLoad", mapOf(
                    "code" to (err.code ?: -1),
                    "message" to (err.message ?: "Unknown error")
                ))
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

    private fun sendEvent(event: String, error: Map<String, Any>? = null) {
        val arguments = mutableMapOf<String, Any>(
            "adId" to adId,
            "event" to event
        )
        error?.let { arguments["error"] = it }

        channel.invokeMethod("onAdEvent", arguments)
    }
}
