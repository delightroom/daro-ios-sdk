package so.daro.flutter.native

import android.content.Context
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class DaroNativeAdViewFactory(
    private val context: Context,
    private val messenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    private val factoryRegistry = mutableMapOf<String, DaroNativeAdFactory>()

    fun registerFactory(factory: DaroNativeAdFactory, factoryId: String) {
        factoryRegistry[factoryId] = factory
    }

    override fun create(
        context: Context,
        viewId: Int,
        args: Any?
    ): PlatformView {
        val params = args as? Map<*, *> ?: emptyMap<String, Any>()
        val factoryId = params["factoryId"] as? String
            ?: throw IllegalArgumentException("factoryId is required")
        val adUnitId = params["adUnitId"] as? String
            ?: throw IllegalArgumentException("adUnitId is required")

        val factory = factoryRegistry[factoryId]
            ?: throw IllegalStateException("Factory not registered: $factoryId")

        return DaroNativeAdPlatformView(
            context,
            viewId,
            adUnitId,
            factory,
            messenger
        )
    }
}
