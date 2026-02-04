import Flutter
import Daro

class DaroBannerAdViewFactory: NSObject, FlutterPlatformViewFactory {
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
        guard let params = args as? [String: Any],
              let adUnitId = params["adUnitId"] as? String,
              let sizeString = params["size"] as? String else {
            fatalError("Invalid arguments for DaroBannerAdViewFactory: \(String(describing: args))")
        }

        let bannerSize: DaroAdBannerSize = sizeString == "mrec" ? .MREC : .banner

        return DaroBannerAdPlatformView(
            frame: frame,
            viewId: viewId,
            adUnitId: adUnitId,
            bannerSize: bannerSize,
            messenger: messenger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
