import '../internal/ad_instance_manager.dart';
import '../models/daro_ad_info.dart';
import '../models/daro_ad_load_error.dart';
import 'daro_ad_choices_position.dart';

class DaroNativeAd {
  final String adUnitId;
  final String factoryId;
  final DaroAdChoicesPosition preferredAdChoicesPosition;
  final void Function(DaroAdInfo adInfo)? onAdLoaded;
  final void Function(DaroAdLoadError error)? onAdFailedToLoad;
  final void Function(DaroAdInfo adInfo)? onAdClicked;
  final void Function(DaroAdInfo adInfo)? onAdImpression;

  late final int adId;
  final AdInstanceManager _manager = AdInstanceManager.instance;

  DaroNativeAd({
    required this.adUnitId,
    required this.factoryId,
    this.preferredAdChoicesPosition = DaroAdChoicesPosition.bottomRight,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
    this.onAdImpression,
  }) {
    adId = _manager.generateId();
    _manager.register(adId, _handleEvent);
  }

  DaroAdInfo _createAdInfo() {
    return DaroAdInfo(adUnitId: adUnitId, format: 'native');
  }

  void _handleEvent(String event, Map<dynamic, dynamic> args) {
    switch (event) {
      case 'onAdLoaded':
        onAdLoaded?.call(_createAdInfo());
        break;
      case 'onAdFailedToLoad':
        final errorMap = args['error'] as Map?;
        if (errorMap != null) {
          onAdFailedToLoad?.call(DaroAdLoadError(
            code: errorMap['code'] as int? ?? -1,
            message: errorMap['message'] as String? ?? 'Unknown error',
            adUnitId: adUnitId,
          ));
        }
        break;
      case 'onAdClicked':
        onAdClicked?.call(_createAdInfo());
        break;
      case 'onAdImpression':
        onAdImpression?.call(_createAdInfo());
        break;
    }
  }

  Future<void> load() async {
    _manager.markReadyForView(adId);
    await _manager.invoke('loadNativeAd', {
      'adId': adId,
      'adUnitId': adUnitId,
      'factoryId': factoryId,
      'preferredAdChoicesPosition': preferredAdChoicesPosition.name,
    });
  }

  Future<void> dispose() async {
    _manager.unregister(adId);
    await _manager.invoke('disposeAd', {
      'adId': adId,
    });
  }
}
