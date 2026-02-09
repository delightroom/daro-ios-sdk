import Flutter
import Daro

class DaroLineNativeAdViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let params = args as? [String: Any] ?? [:]
        let adUnitId = params["adUnitId"] as? String ?? ""

        let configuration = DaroLineNativeAdConfiguration()

        if let backgroundColor = params["backgroundColor"] as? [String: Any],
           let color = colorFromMap(backgroundColor) {
            configuration.backgroundColor = color
        }
        if let contentColor = params["contentColor"] as? [String: Any],
           let color = colorFromMap(contentColor) {
            configuration.titleTextColor = color
        }
        if let adMarkLabelTextColor = params["adMarkLabelTextColor"] as? [String: Any],
           let color = colorFromMap(adMarkLabelTextColor) {
            configuration.adMarkTextColor = color
        }
        if let adMarkLabelBackgroundColor = params["adMarkLabelBackgroundColor"] as? [String: Any],
           let color = colorFromMap(adMarkLabelBackgroundColor) {
            configuration.adMarkBackgroundColor = color
        }

        return DaroLineNativeAdPlatformView(
            frame: frame,
            viewId: viewId,
            adUnitId: adUnitId,
            configuration: configuration,
            messenger: messenger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    private func colorFromMap(_ map: [String: Any]) -> UIColor? {
        guard let r = map["r"] as? Int,
              let g = map["g"] as? Int,
              let b = map["b"] as? Int,
              let a = map["a"] as? Int else {
            return nil
        }
        return UIColor(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }
}
