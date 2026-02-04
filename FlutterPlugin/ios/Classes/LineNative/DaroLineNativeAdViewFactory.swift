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

        if let backgroundColor = params["backgroundColor"] as? String {
            configuration.backgroundColor = colorFromHex(backgroundColor)
        }
        if let contentColor = params["contentColor"] as? String {
            configuration.titleTextColor = colorFromHex(contentColor)
        }
        if let adMarkLabelTextColor = params["adMarkLabelTextColor"] as? String {
            configuration.adMarkTextColor = colorFromHex(adMarkLabelTextColor)
        }
        if let adMarkLabelBackgroundColor = params["adMarkLabelBackgroundColor"] as? String {
            configuration.adMarkBackgroundColor = colorFromHex(adMarkLabelBackgroundColor)
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

    private func colorFromHex(_ hexString: String) -> UIColor {
        var hex = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if hex.hasPrefix("#") {
            hex.removeFirst()
        }

        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)

        if hex.count == 8 {
            return UIColor(
                red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(rgbValue & 0x000000FF) / 255.0
            )
        } else {
            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        }
    }
}
