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

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        guard let params = args as? [String: Any],
              let factoryId = params["factoryId"] as? String,
              let adUnitId = params["adUnitId"] as? String,
              let factory = factoryRegistry[factoryId] else {
            fatalError("Factory not registered: \(String(describing: args))")
        }

        return DaroNativeAdPlatformView(
            frame: frame,
            viewId: viewId,
            adUnitId: adUnitId,
            factory: factory,
            messenger: messenger
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
