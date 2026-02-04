package so.daro.flutter.linenative

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class DaroLineNativeAdViewFactory(
    private val context: Context,
    private val messenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(
        context: Context,
        viewId: Int,
        args: Any?
    ): PlatformView {
        val params = args as? Map<*, *> ?: emptyMap<String, Any>()
        val adUnitId = params["adUnitId"] as? String
            ?: throw IllegalArgumentException("adUnitId is required")

        val backgroundColor = params["backgroundColor"] as? String
        val contentColor = params["contentColor"] as? String
        val adMarkLabelTextColor = params["adMarkLabelTextColor"] as? String
        val adMarkLabelBackgroundColor = params["adMarkLabelBackgroundColor"] as? String

        return DaroLineNativeAdPlatformView(
            context,
            viewId,
            adUnitId,
            backgroundColor,
            contentColor,
            adMarkLabelTextColor,
            adMarkLabelBackgroundColor,
            messenger
        )
    }
}
