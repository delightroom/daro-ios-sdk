package so.daro.flutter.native

import android.view.View
import droom.daro.core.model.DaroNativeAdBinder
import droom.daro.core.model.DaroNativeAdChoicePlacement

interface DaroNativeAdFactory {
    fun createNativeAdView(): View

    fun createAdBinder(
        view: View,
        adChoicePlacement: DaroNativeAdChoicePlacement,
    ): DaroNativeAdBinder
}
