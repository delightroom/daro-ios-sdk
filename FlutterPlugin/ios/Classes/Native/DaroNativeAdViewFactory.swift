import Flutter
import Daro

class DaroNativeAdViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    private var factoryRegistry: [String: DaroNativeAdFactory] = [:]

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func registerFactory(_ factory: DaroNativeAdFactory, withId id: String) {
        factoryRegistry[id] = factory
    }

    func getFactory(withId id: String) -> DaroNativeAdFactory? {
        return factoryRegistry[id]
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        guard let params = args as? [String: Any],
              let adId = params["adId"] as? Int,
              let platformView = DaroAdInstanceManager.shared.get(forId: adId) else {
            fatalError("Native ad not found in cache. Call load() before mounting widget. Args: \(String(describing: args))")
        }

        return platformView
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
