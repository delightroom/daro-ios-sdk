import UIKit
import Daro

public protocol DaroNativeAdFactory {
    func createNativeAdView(
        unit: DaroAdUnit,
        preferredAdChoicesPosition: DaroAdChoicesPosition
    ) -> DaroAdNativeView
}
