package so.daro.flutter.linenative

import android.content.Context
import android.graphics.Color
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

        val backgroundColor = parseColorFromMap(params["backgroundColor"])
        val contentColor = parseColorFromMap(params["contentColor"])
        val adMarkLabelTextColor = parseColorFromMap(params["adMarkLabelTextColor"])
        val adMarkLabelBackgroundColor = parseColorFromMap(params["adMarkLabelBackgroundColor"])

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

    private fun parseColorFromMap(value: Any?): Int? {
        val map = value as? Map<*, *> ?: return null
        val r = (map["r"] as? Number)?.toInt() ?: return null
        val g = (map["g"] as? Number)?.toInt() ?: return null
        val b = (map["b"] as? Number)?.toInt() ?: return null
        val a = (map["a"] as? Number)?.toInt() ?: return null
        return Color.argb(a, r, g, b)
    }
}
