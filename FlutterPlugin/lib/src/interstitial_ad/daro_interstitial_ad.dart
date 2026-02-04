import 'dart:async';
import 'package:flutter/services.dart';
import '../models/daro_ad_info.dart';
import '../models/daro_ad_load_error.dart';
import '../models/daro_ad_display_error.dart';
import '../internal/ad_event_data.dart';

typedef OnAdLoadSuccess = void Function(DaroAdInfo adInfo);
typedef OnAdLoadFail = void Function(DaroAdLoadError error);
typedef OnAdImpression = void Function(DaroAdInfo adInfo);
typedef OnAdClicked = void Function(DaroAdInfo adInfo);
typedef OnAdShown = void Function(DaroAdInfo adInfo);
typedef OnAdFailedToShow = void Function(DaroAdDisplayError error);
typedef OnAdDismiss = void Function(DaroAdInfo adInfo);

class DaroInterstitialAd {
  static const MethodChannel _methodChannel =
      MethodChannel('daro_flutter/interstitial');
  static const EventChannel _eventChannel =
      EventChannel('daro_flutter/interstitial_events');

  static final Map<String, DaroInterstitialAd> _instances = {};
  static StreamSubscription<dynamic>? _eventSubscription;

  final String adUnitId;
  final String? placement;

  OnAdLoadSuccess? onAdLoadSuccess;
  OnAdLoadFail? onAdLoadFail;
  OnAdImpression? onAdImpression;
  OnAdClicked? onAdClicked;
  OnAdShown? onAdShown;
  OnAdFailedToShow? onAdFailedToShow;
  OnAdDismiss? onAdDismiss;

  bool _isLoading = false;

  DaroInterstitialAd({
    required this.adUnitId,
    this.placement,
    this.onAdLoadSuccess,
    this.onAdLoadFail,
    this.onAdImpression,
    this.onAdClicked,
    this.onAdShown,
    this.onAdFailedToShow,
    this.onAdDismiss,
  }) {
    _instances[adUnitId] = this;
    _ensureEventChannelSetup();
  }

  static void _ensureEventChannelSetup() {
    if (_eventSubscription != null) return;

    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        final eventData = AdEventData.parse(event);
        if (eventData == null) return;

        final instance = _instances[eventData.adUnitId];
        if (instance == null) return;

        switch (eventData.eventType) {
          case 'onAdLoadSuccess':
            _handleAdInfoEvent(eventData.event, instance, instance.onAdLoadSuccess, resetLoading: true);
            break;
          case 'onAdLoadFail':
            _handleErrorEvent(eventData.event, instance, DaroAdLoadError.fromMap, instance.onAdLoadFail, resetLoading: true);
            break;
          case 'onAdImpression':
            _handleAdInfoEvent(eventData.event, instance, instance.onAdImpression);
            break;
          case 'onAdClicked':
            _handleAdInfoEvent(eventData.event, instance, instance.onAdClicked);
            break;
          case 'onAdShown':
            _handleAdInfoEvent(eventData.event, instance, instance.onAdShown);
            break;
          case 'onAdFailedToShow':
            _handleErrorEvent(eventData.event, instance, DaroAdDisplayError.fromMap, instance.onAdFailedToShow);
            break;
          case 'onAdDismiss':
            _handleAdInfoEvent(eventData.event, instance, instance.onAdDismiss);
            break;
        }
      },
      onError: (dynamic error) {
        print('DaroInterstitialAd event channel error: $error');
      },
    );
  }

  static void _handleAdInfoEvent(
    Map<String, dynamic> event,
    DaroInterstitialAd instance,
    void Function(DaroAdInfo)? callback,
    {bool resetLoading = false}
  ) {
    final rawAdInfo = event['adInfo'];
    if (rawAdInfo is Map) {
      if (resetLoading) instance._isLoading = false;
      callback?.call(DaroAdInfo.fromMap(Map<String, dynamic>.from(rawAdInfo)));
    }
  }

  static void _handleErrorEvent<T>(
    Map<String, dynamic> event,
    DaroInterstitialAd instance,
    T Function(Map<String, dynamic>) fromMap,
    void Function(T)? callback,
    {bool resetLoading = false}
  ) {
    final rawError = event['error'];
    if (rawError is Map) {
      if (resetLoading) instance._isLoading = false;
      callback?.call(fromMap(Map<String, dynamic>.from(rawError)));
    }
  }

  Future<void> load() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;

    try {
      await _methodChannel.invokeMethod('loadAd', {
        'adUnitId': adUnitId,
        'placement': placement,
      });
    } catch (e) {
      _isLoading = false;
      rethrow;
    }
  }

  Future<bool> isReady() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('isAdReady', {
        'adUnitId': adUnitId,
      });
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> show() async {
    final ready = await isReady();
    if (!ready) {
      throw Exception('Ad not ready. Load the ad first or check isReady().');
    }

    await _methodChannel.invokeMethod('showAd', {
      'adUnitId': adUnitId,
    });
  }

  Future<void> destroy() async {
    try {
      await _methodChannel.invokeMethod('destroyAd', {
        'adUnitId': adUnitId,
      });
      _instances.remove(adUnitId);
      _isLoading = false;
    } catch (e) {
      rethrow;
    }
  }

  static void disposeAll() {
    _eventSubscription?.cancel();
    _eventSubscription = null;
    _instances.clear();
  }
}
