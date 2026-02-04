package so.daro.flutter

import android.app.Application
import android.content.Context
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import droom.daro.SDKConfig
import droom.daro.a.Daro
import so.daro.flutter.native.DaroNativeAdFactory
import so.daro.flutter.native.DaroNativeAdViewFactory
import so.daro.flutter.banner.DaroBannerAdViewFactory
import so.daro.flutter.linenative.DaroLineNativeAdViewFactory

class DaroFlutterPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private lateinit var context: Context
  private var interstitialAdManager: DaroInterstitialAdManager? = null
  private var rewardedAdManager: DaroRewardedAdManager? = null
  private var appOpenAdManager: DaroFlutterAppOpenAdManager? = null
  private var lightPopupAdManager: DaroFlutterLightPopupAdManager? = null

  companion object {
    private var nativeAdViewFactory: DaroNativeAdViewFactory? = null

    /**
     * 네이티브 광고 팩토리를 등록할 수 있는 공개 메서드
     *
     * @param factory DaroNativeAdFactory 인터페이스를 구현한 객체
     * @param factoryId 팩토리를 식별하는 고유 ID
     */
    @JvmStatic
    fun registerNativeAdFactory(factory: DaroNativeAdFactory, factoryId: String) {
      nativeAdViewFactory?.registerFactory(factory, factoryId)
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "daro_flutter")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext

    val interstitialMethodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "daro_flutter/interstitial")
    val interstitialEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "daro_flutter/interstitial_events")

    val manager = DaroInterstitialAdManager()
    interstitialAdManager = manager

    interstitialMethodChannel.setMethodCallHandler(manager)
    interstitialEventChannel.setStreamHandler(manager)

    val rewardedMethodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "daro_flutter/rewarded")
    val rewardedEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "daro_flutter/rewarded_events")

    val rewardedManager = DaroRewardedAdManager()
    rewardedAdManager = rewardedManager

    rewardedMethodChannel.setMethodCallHandler(rewardedManager)
    rewardedEventChannel.setStreamHandler(rewardedManager)

    val appOpenMethodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "daro_flutter/appopen")
    val appOpenEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "daro_flutter/appopen_events")

    val appOpenManager = DaroFlutterAppOpenAdManager()
    appOpenManager.setApplication(context.applicationContext as? Application)
    appOpenAdManager = appOpenManager

    appOpenMethodChannel.setMethodCallHandler(appOpenManager)
    appOpenEventChannel.setStreamHandler(appOpenManager)

    val lightPopupMethodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "daro_flutter/lightpopup")
    val lightPopupEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "daro_flutter/lightpopup_events")

    val lightPopupManager = DaroFlutterLightPopupAdManager()
    lightPopupManager.setContext(context)
    lightPopupAdManager = lightPopupManager

    lightPopupMethodChannel.setMethodCallHandler(lightPopupManager)
    lightPopupEventChannel.setStreamHandler(lightPopupManager)

    val nativeFactory = DaroNativeAdViewFactory(context, flutterPluginBinding.binaryMessenger)
    flutterPluginBinding.platformViewRegistry.registerViewFactory(
      "daro_native_ad_view",
      nativeFactory
    )
    nativeAdViewFactory = nativeFactory

    // 배너 광고 팩토리 등록
    val bannerFactory = DaroBannerAdViewFactory(context, flutterPluginBinding.binaryMessenger)
    flutterPluginBinding.platformViewRegistry.registerViewFactory(
      "daro_banner_ad_view",
      bannerFactory
    )

    // 라인 네이티브 광고 팩토리 등록
    val lineNativeFactory = DaroLineNativeAdViewFactory(context, flutterPluginBinding.binaryMessenger)
    flutterPluginBinding.platformViewRegistry.registerViewFactory(
      "daro_line_native_ad_view",
      lineNativeFactory
    )
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${Build.VERSION.RELEASE}")
      }
      "initialize" -> {
        initializeDaroSDK(call, result)
      }
      "setAppMuted" -> {
        val muted = call.arguments as? Boolean ?: false
        Daro.setAppMuted(muted)
        result.success(null)
      }
      "setUserId" -> {
        val userId = call.arguments as? String ?: ""
        Daro.setUserId(context, userId)
        result.success(null)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun initializeDaroSDK(call: MethodCall, result: Result) {
    try {
      val application = context.applicationContext as? Application
      if (application == null) {
        result.error(
          "INIT_ERROR",
          "Failed to get Application context",
          null
        )
        return
      }

      val args = call.arguments as? Map<*, *>
      val isDebugMode = args?.get("isDebugMode") as? Boolean ?: false

      Daro.init(
        application = application,
        sdkConfig = SDKConfig.Builder()
          .setDebugMode(isDebugMode)
          .build()
      )

      val hasGdprConsent = args?.get("hasGdprConsent") as? Boolean
      val gdprString = args?.get("gdprConsentString") as? String ?: ""
      hasGdprConsent?.let {
        if (it) Daro.grantGdpr(context, gdprString)
        else Daro.rejectGdpr(context, gdprString)
      }

      val doNotSell = args?.get("doNotSell") as? Boolean
      val ccpaString = args?.get("ccpaConsentString") as? String ?: ""
      doNotSell?.let {
        if (it) Daro.rejectCCPA(context, ccpaString)
        else Daro.grantCCPA(context, ccpaString)
      }

      val coppa = args?.get("isTaggedForChildDirectedTreatment") as? Boolean
      coppa?.let {
        if (it) Daro.grantCOPPA(context)
        else Daro.rejectCOPPA(context)
      }

      result.success(null)
    } catch (e: Exception) {
      result.error(
        "INIT_ERROR",
        "Daro SDK initialization failed: ${e.message}",
        e.toString()
      )
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    interstitialAdManager?.setActivity(binding.activity)
    rewardedAdManager?.setActivity(binding.activity)
    appOpenAdManager?.setActivity(binding.activity)
    lightPopupAdManager?.setActivity(binding.activity)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    interstitialAdManager?.setActivity(null)
    rewardedAdManager?.setActivity(null)
    appOpenAdManager?.setActivity(null)
    lightPopupAdManager?.setActivity(null)
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    interstitialAdManager?.setActivity(binding.activity)
    rewardedAdManager?.setActivity(binding.activity)
    appOpenAdManager?.setActivity(binding.activity)
    lightPopupAdManager?.setActivity(binding.activity)
  }

  override fun onDetachedFromActivity() {
    interstitialAdManager?.setActivity(null)
    rewardedAdManager?.setActivity(null)
    appOpenAdManager?.setActivity(null)
    lightPopupAdManager?.setActivity(null)
  }
}
