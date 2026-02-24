import 'package:flutter/services.dart';

typedef AdEventCallback = void Function(String event, Map<dynamic, dynamic> args);

class AdInstanceManager {
  AdInstanceManager._();
  static final AdInstanceManager instance = AdInstanceManager._();

  static const MethodChannel _channel = MethodChannel('daro_flutter/ad_manager');

  int _nextAdId = 0;
  final Map<int, AdEventCallback> _ads = {};
  final Set<int> _readyForViewIds = {};
  bool _isHandlerSet = false;

  int generateId() => _nextAdId++;

  void register(int adId, AdEventCallback callback) {
    _ensureHandlerSet();
    _ads[adId] = callback;
  }

  void unregister(int adId) {
    _ads.remove(adId);
    _readyForViewIds.remove(adId);
  }

  void markReadyForView(int adId) => _readyForViewIds.add(adId);
  bool isReadyForView(int adId) => _readyForViewIds.contains(adId);

  Future<void> invoke(String method, Map<String, dynamic> arguments) {
    return _channel.invokeMethod(method, arguments);
  }

  void _ensureHandlerSet() {
    if (_isHandlerSet) return;
    _isHandlerSet = true;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onAdEvent') {
        final args = call.arguments as Map<dynamic, dynamic>;
        final adId = args['adId'] as int;
        final event = args['event'] as String;

        final callback = _ads[adId];
        callback?.call(event, args);
      }
    });
  }
}
