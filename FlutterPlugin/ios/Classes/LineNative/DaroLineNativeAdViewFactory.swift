import Flutter

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
        guard let params = args as? [String: Any],
              let adId = params["adId"] as? Int,
              let platformView = DaroAdInstanceManager.shared.get(forId: adId) else {
            fatalError("Line native ad not found in cache. Call load() before mounting widget. Args: \(String(describing: args))")
        }
        return platformView
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
