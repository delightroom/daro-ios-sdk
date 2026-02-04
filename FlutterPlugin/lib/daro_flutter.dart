library daro_flutter;

import 'dart:async';
import 'package:flutter/services.dart';

export 'src/models/daro_ad_info.dart';
export 'src/models/daro_ad_load_error.dart';
export 'src/models/daro_ad_display_error.dart';
export 'src/models/daro_reward_item.dart';
export 'src/interstitial_ad/daro_interstitial_ad.dart';
export 'src/rewarded_ad/daro_rewarded_ad.dart';
export 'src/appopen_ad/daro_appopen_ad.dart';
export 'src/lightpopup_ad/daro_lightpopup_ad.dart';
export 'src/native_ad/daro_native_ad_widget.dart';
export 'src/native_ad/daro_line_native_ad_widget.dart';
export 'src/banner/daro_banner_ad_widget.dart';
export 'src/banner/daro_banner_size.dart';

class DaroFlutter {
  static const MethodChannel _channel = MethodChannel('daro_flutter');
  static Completer<void>? _initCompleter;

  // === Pre-initialization Settings (Privacy) ===

  static bool isDebugMode = false;

  static bool? hasGdprConsent;
  static String? gdprConsentString;

  static bool? doNotSell;
  static String? ccpaConsentString;

  static bool? isTaggedForChildDirectedTreatment;

  // === Public API ===

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> initialize() async {
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<void>();

    try {
      await _channel.invokeMethod('initialize', {
        'isDebugMode': isDebugMode,
        if (hasGdprConsent != null) 'hasGdprConsent': hasGdprConsent,
        if (gdprConsentString != null) 'gdprConsentString': gdprConsentString,
        if (doNotSell != null) 'doNotSell': doNotSell,
        if (ccpaConsentString != null) 'ccpaConsentString': ccpaConsentString,
        if (isTaggedForChildDirectedTreatment != null)
          'isTaggedForChildDirectedTreatment': isTaggedForChildDirectedTreatment,
      });
      _initCompleter!.complete();
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null;
      rethrow;
    }

    return _initCompleter!.future;
  }

  static Future<void> setAppMuted(bool muted) async {
    await _channel.invokeMethod('setAppMuted', muted);
  }

  static Future<void> setUserId(String userId) async {
    await _channel.invokeMethod('setUserId', userId);
  }

  static void resetForTesting() {
    _initCompleter = null;
    isDebugMode = false;
    hasGdprConsent = null;
    gdprConsentString = null;
    doNotSell = null;
    ccpaConsentString = null;
    isTaggedForChildDirectedTreatment = null;
  }
}

String sayHello() {
  return 'Hello World from Daro Flutter!';
}
