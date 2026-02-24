import Flutter
import UIKit
import Daro

public class DaroFlutterPlugin: NSObject, FlutterPlugin {
  private var interstitialAdManager: DaroInterstitialAdManager?
  private var rewardedAdManager: DaroRewardedAdManager?
  private var appOpenAdManager: DaroAppOpenAdManager?
  private var lightPopupAdManager: DaroLightPopupAdManager?
  private static var nativeAdViewFactory: DaroNativeAdViewFactory?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "daro_flutter", binaryMessenger: registrar.messenger())
    let instance = DaroFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)

    let interstitialMethodChannel = FlutterMethodChannel(name: "daro_flutter/interstitial", binaryMessenger: registrar.messenger())
    let interstitialEventChannel = FlutterEventChannel(name: "daro_flutter/interstitial_events", binaryMessenger: registrar.messenger())

    let interstitialManager = DaroInterstitialAdManager()
    instance.interstitialAdManager = interstitialManager

    interstitialMethodChannel.setMethodCallHandler { call, result in
      interstitialManager.handle(call, result: result)
    }
    interstitialEventChannel.setStreamHandler(interstitialManager)

    let rewardedMethodChannel = FlutterMethodChannel(name: "daro_flutter/rewarded", binaryMessenger: registrar.messenger())
    let rewardedEventChannel = FlutterEventChannel(name: "daro_flutter/rewarded_events", binaryMessenger: registrar.messenger())

    let rewardedManager = DaroRewardedAdManager()
    instance.rewardedAdManager = rewardedManager

    rewardedMethodChannel.setMethodCallHandler { call, result in
      rewardedManager.handle(call, result: result)
    }
    rewardedEventChannel.setStreamHandler(rewardedManager)

    let appOpenMethodChannel = FlutterMethodChannel(name: "daro_flutter/appopen", binaryMessenger: registrar.messenger())
    let appOpenEventChannel = FlutterEventChannel(name: "daro_flutter/appopen_events", binaryMessenger: registrar.messenger())

    let appOpenManager = DaroAppOpenAdManager()
    instance.appOpenAdManager = appOpenManager

    appOpenMethodChannel.setMethodCallHandler { call, result in
      appOpenManager.handle(call, result: result)
    }
    appOpenEventChannel.setStreamHandler(appOpenManager)

    let lightPopupMethodChannel = FlutterMethodChannel(name: "daro_flutter/lightpopup", binaryMessenger: registrar.messenger())
    let lightPopupEventChannel = FlutterEventChannel(name: "daro_flutter/lightpopup_events", binaryMessenger: registrar.messenger())

    let lightPopupManager = DaroLightPopupAdManager()
    instance.lightPopupAdManager = lightPopupManager

    lightPopupMethodChannel.setMethodCallHandler { call, result in
      lightPopupManager.handle(call, result: result)
    }
    lightPopupEventChannel.setStreamHandler(lightPopupManager)

    // ad_manager 채널: view-based 광고(배너/네이티브/라인네이티브) 로드/파괴
    let adManagerChannel = FlutterMethodChannel(
      name: "daro_flutter/ad_manager",
      binaryMessenger: registrar.messenger()
    )
    adManagerChannel.setMethodCallHandler { call, result in
      instance.handleAdManager(call, result: result, messenger: registrar.messenger(), channel: adManagerChannel)
    }

    // 네이티브 광고 팩토리 등록
    let nativeFactory = DaroNativeAdViewFactory(messenger: registrar.messenger())
    registrar.register(
      nativeFactory,
      withId: "daro_native_ad_view"
    )
    Self.nativeAdViewFactory = nativeFactory

    // 배너 광고 팩토리 등록
    let bannerFactory = DaroBannerAdViewFactory(messenger: registrar.messenger())
    registrar.register(
      bannerFactory,
      withId: "daro_banner_ad_view"
    )

    // 라인 네이티브 광고 팩토리 등록
    let lineNativeFactory = DaroLineNativeAdViewFactory(messenger: registrar.messenger())
    registrar.register(
      lineNativeFactory,
      withId: "daro_line_native_ad_view"
    )
  }

  /// 네이티브 광고 팩토리를 등록할 수 있는 공개 메서드
  public static func registerNativeAdFactory(
    _ factory: DaroNativeAdFactory,
    factoryId: String
  ) {
    nativeAdViewFactory?.registerFactory(factory, withId: factoryId)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "initialize":
      initializeDaroSDK(call: call, result: result)
    case "setAppMuted":
      let muted = call.arguments as? Bool ?? false
      DaroAds.shared.setAppMuted(muted)
      result(nil)
    case "setUserId":
      let userId = call.arguments as? String
      DaroAds.shared.userId = userId
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleAdManager(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult,
    messenger: FlutterBinaryMessenger,
    channel: FlutterMethodChannel
  ) {
    let args = call.arguments as? [String: Any] ?? [:]

    switch call.method {
    case "loadBannerAd":
      guard let adId = args["adId"] as? Int,
            let adUnitId = args["adUnitId"] as? String,
            let sizeString = args["size"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
        return
      }

      let bannerSize: DaroAdBannerSize = sizeString == "mrec" ? .MREC : .banner
      let platformView = DaroBannerAdPlatformView(
        frame: .zero,
        adId: adId,
        adUnitId: adUnitId,
        bannerSize: bannerSize,
        channel: channel
      )
      DaroAdInstanceManager.shared.store(platformView, forId: adId)
      result(nil)

    case "loadNativeAd":
      guard let adId = args["adId"] as? Int,
            let adUnitId = args["adUnitId"] as? String,
            let factoryId = args["factoryId"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
        return
      }

      guard let factory = Self.nativeAdViewFactory?.getFactory(withId: factoryId) else {
        result(FlutterError(code: "FACTORY_NOT_FOUND", message: "Factory not registered: \(factoryId)", details: nil))
        return
      }

      let platformView = DaroNativeAdPlatformView(
        frame: .zero,
        adId: adId,
        adUnitId: adUnitId,
        factory: factory,
        channel: channel
      )
      DaroAdInstanceManager.shared.store(platformView, forId: adId)
      result(nil)

    case "loadLineNativeAd":
      guard let adId = args["adId"] as? Int,
            let adUnitId = args["adUnitId"] as? String else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
        return
      }

      let configuration = DaroLineNativeAdConfiguration()

      if let backgroundColor = args["backgroundColor"] as? [String: Any],
         let color = colorFromMap(backgroundColor) {
        configuration.backgroundColor = color
      }
      if let contentColor = args["contentColor"] as? [String: Any],
         let color = colorFromMap(contentColor) {
        configuration.titleTextColor = color
      }
      if let adMarkLabelTextColor = args["adMarkLabelTextColor"] as? [String: Any],
         let color = colorFromMap(adMarkLabelTextColor) {
        configuration.adMarkTextColor = color
      }
      if let adMarkLabelBackgroundColor = args["adMarkLabelBackgroundColor"] as? [String: Any],
         let color = colorFromMap(adMarkLabelBackgroundColor) {
        configuration.adMarkBackgroundColor = color
      }

      let platformView = DaroLineNativeAdPlatformView(
        frame: .zero,
        adId: adId,
        adUnitId: adUnitId,
        configuration: configuration,
        channel: channel
      )
      DaroAdInstanceManager.shared.store(platformView, forId: adId)
      result(nil)

    case "disposeAd":
      guard let adId = args["adId"] as? Int else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing adId", details: nil))
        return
      }
      DaroAdInstanceManager.shared.remove(forId: adId)
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
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

  private func initializeDaroSDK(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]

    if let isDebug = args?["isDebugMode"] as? Bool {
      DaroAds.shared.logLevel = isDebug ? .debug : .off
    }
    if let hasConsent = args?["hasGdprConsent"] as? Bool {
      DaroAds.shared.hasUserConsent = hasConsent
    }
    if let gdprString = args?["gdprConsentString"] as? String {
      DaroAds.shared.gdprConsentString = gdprString
    }
    if let doNotSell = args?["doNotSell"] as? Bool {
      DaroAds.shared.doNotSell = doNotSell
    }
    if let ccpaString = args?["ccpaConsentString"] as? String {
      DaroAds.shared.ccpaString = ccpaString
    }
    if let coppa = args?["isTaggedForChildDirectedTreatment"] as? Bool {
      DaroAds.shared.isTaggedForChildDirectedTreatment = coppa
    }

    DaroAds.shared.initialized { error in
      if let error = error {
        NSLog("[DaroFlutter] initialization failed: \(error.localizedDescription)")
      }
    }
    result(nil)
  }
}
