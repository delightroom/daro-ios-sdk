package so.daro.flutter.native

import android.view.View
import droom.daro.core.model.DaroNativeAdBinder

interface DaroNativeAdFactory {
    fun createNativeAdView(): View
    
    fun createAdBinder(view: View): DaroNativeAdBinder
}
