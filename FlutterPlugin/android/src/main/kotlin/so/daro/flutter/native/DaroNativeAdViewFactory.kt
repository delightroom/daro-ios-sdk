package so.daro.flutter.native

import android.content.Context
import android.view.View
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import so.daro.flutter.DaroAdInstanceManager

class DaroNativeAdViewFactory(
    private val context: Context,
    private val messenger: BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    private val factoryRegistry = mutableMapOf<String, DaroNativeAdFactory>()

    fun registerFactory(factory: DaroNativeAdFactory, factoryId: String) {
        factoryRegistry[factoryId] = factory
    }

    fun getFactory(factoryId: String): DaroNativeAdFactory? {
        return factoryRegistry[factoryId]
    }

    override fun create(
        context: Context,
        viewId: Int,
        args: Any?
    ): PlatformView {
        val params = args as? Map<*, *> ?: emptyMap<String, Any>()
        val adId = params["adId"] as? Int

        if (adId != null) {
            DaroAdInstanceManager.get(adId)?.let { return it }
        }

        return object : PlatformView {
            override fun getView(): View = View(context)
            override fun dispose() {}
        }
    }
}
