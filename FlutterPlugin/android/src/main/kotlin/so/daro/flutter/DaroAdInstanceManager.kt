package so.daro.flutter

import io.flutter.plugin.platform.PlatformView

object DaroAdInstanceManager {
    private val ads = mutableMapOf<Int, PlatformView>()

    fun store(ad: PlatformView, adId: Int) {
        ads[adId] = ad
    }

    fun get(adId: Int): PlatformView? {
        return ads[adId]
    }

    fun remove(adId: Int) {
        val ad = ads.remove(adId)
        ad?.dispose()
    }
}
