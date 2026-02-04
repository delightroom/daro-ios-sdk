package so.daro.flutter.banner

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class DaroBannerAdViewFactory(
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
        val sizeString = params["size"] as? String
            ?: throw IllegalArgumentException("size is required")

        return DaroBannerAdPlatformView(
            context,
            viewId,
            adUnitId,
            sizeString,
            messenger
        )
    }
}
