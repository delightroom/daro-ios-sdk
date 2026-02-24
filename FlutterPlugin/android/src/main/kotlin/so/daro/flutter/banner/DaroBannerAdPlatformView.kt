package so.daro.flutter.banner

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import droom.daro.core.adunit.DaroBannerAdUnit
import droom.daro.core.model.DaroBannerSize
import droom.daro.view.DaroBannerAdView
import droom.daro.view.DaroAdViewListener
import droom.daro.core.model.DaroAdInfo
import droom.daro.core.model.DaroAdLoadError
import droom.daro.core.model.DaroViewAd

class DaroBannerAdPlatformView(
    context: Context,
    private val adId: Int,
    private val adUnitId: String,
    private val sizeString: String,
    private val channel: MethodChannel
) : PlatformView {

    private val containerView: FrameLayout = FrameLayout(context)
    private var bannerAdView: DaroBannerAdView? = null

    init {
        setupBannerAd(context)
    }

    override fun getView(): View = containerView

    override fun dispose() {
        bannerAdView?.destroy()
        bannerAdView = null
    }

    private fun setupBannerAd(context: Context) {
        val bannerSize = if (sizeString == "mrec") {
            DaroBannerSize.MREC
        } else {
            DaroBannerSize.Banner
        }

        val adUnit = DaroBannerAdUnit(
            key = adUnitId,
            placement = "",
            bannerSize = bannerSize
        )

        val bannerAdView = DaroBannerAdView(context, adUnit)
        this.bannerAdView = bannerAdView

        bannerAdView.setListener(object : DaroAdViewListener {
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

        val layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        containerView.addView(bannerAdView, layoutParams)

        bannerAdView.loadAd()
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
