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
  ///
  /// - Parameters:
  ///   - factory: DaroNativeAdFactory 프로토콜을 구현한 객체
  ///   - factoryId: 팩토리를 식별하는 고유 ID
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
