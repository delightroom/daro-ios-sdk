package so.daro.flutter.linenative

import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import droom.daro.core.adunit.DaroNativeAdUnit
import droom.daro.core.model.DaroAdInfo
import droom.daro.core.model.DaroAdLoadError
import droom.daro.core.model.DaroNativeAdBinder
import droom.daro.core.model.DaroViewAd
import droom.daro.core.model.nativetemplate.DaroNativeAdTemplate
import droom.daro.view.DaroAdViewListener
import droom.daro.view.DaroNativeAdView

class DaroLineNativeAdPlatformView(
    context: Context,
    private val viewId: Int,
    private val adUnitId: String,
    private val backgroundColor: String?,
    private val contentColor: String?,
    private val adMarkLabelTextColor: String?,
    private val adMarkLabelBackgroundColor: String?,
    messenger: BinaryMessenger
) : PlatformView {

    private val containerView: FrameLayout = FrameLayout(context)
    private var nativeAdView: DaroNativeAdView? = null
    private val methodChannel: MethodChannel = MethodChannel(
        messenger,
        "daro_flutter/line_native_ad"
    )

    init {
        setupLineNativeAd(context)
        setupMethodChannel()
    }

    override fun getView(): View = containerView

    override fun dispose() {
        nativeAdView = null
    }

    private fun setupLineNativeAd(context: Context) {
        val adUnit = DaroNativeAdUnit(
            key = adUnitId,
            placement = ""
        )
        val nativeAdView = DaroNativeAdView(context, adUnit)
        this.nativeAdView = nativeAdView

        val template = DaroNativeAdTemplate.LineCenter(
            backgroundColor = parseColor(backgroundColor, Color.TRANSPARENT),
            contentColor = parseColor(contentColor, Color.BLACK),
            adMarkLabelBackgroundColor = parseColor(adMarkLabelBackgroundColor, Color.LTGRAY),
            adMarkLabelTextColor = parseColor(adMarkLabelTextColor, Color.WHITE)
        )
        val adBinder = DaroNativeAdBinder.fromTemplate(context, template)
        nativeAdView.setAdBinder(adBinder)

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

    private fun sendEvent(event: String, error: Map<String, Any>? = null) {
        val arguments = mutableMapOf<String, Any>(
            "viewId" to viewId,
            "event" to event
        )
        error?.let { arguments["error"] = it }

        methodChannel.invokeMethod("onAdEvent", arguments)
    }

    private fun parseColor(hexString: String?, defaultColor: Int): Int {
        if (hexString.isNullOrEmpty()) return defaultColor

        return try {
            val hex = hexString.removePrefix("#")
            when (hex.length) {
                6 -> Color.parseColor("#$hex")
                8 -> {
                    val alpha = hex.substring(0, 2).toInt(16)
                    val rgb = hex.substring(2)
                    Color.parseColor("#$rgb").let { color ->
                        Color.argb(alpha, Color.red(color), Color.green(color), Color.blue(color))
                    }
                }
                else -> defaultColor
            }
        } catch (e: Exception) {
            defaultColor
        }
    }
}
