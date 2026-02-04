import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../models/daro_ad_info.dart';
import '../models/daro_ad_load_error.dart';

class DaroNativeAdWidget extends StatefulWidget {
  /// 네이티브에서 등록한 팩토리 ID
  final String factoryId;

  /// Daro 광고 유닛 ID
  final String adUnitId;

  /// 광고 로드 성공 콜백
  final void Function(DaroAdInfo adInfo)? onAdLoaded;

  /// 광고 로드 실패 콜백
  final void Function(DaroAdLoadError error)? onAdFailedToLoad;

  /// 광고 클릭 콜백
  final void Function(DaroAdInfo adInfo)? onAdClicked;

  /// 광고 노출 콜백
  final void Function(DaroAdInfo adInfo)? onAdImpression;

  const DaroNativeAdWidget({
    Key? key,
    required this.factoryId,
    required this.adUnitId,
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
    this.onAdImpression,
  }) : super(key: key);

  @override
  State<DaroNativeAdWidget> createState() => DaroNativeAdWidgetState();

  static DaroNativeAdWidgetState? of(BuildContext context) {
    return context.findAncestorStateOfType<DaroNativeAdWidgetState>();
  }
}

class DaroNativeAdWidgetState extends State<DaroNativeAdWidget> {
  static const String _viewType = 'daro_native_ad_view';
  static const MethodChannel _channel = MethodChannel('daro_flutter/native_ad');

  int? _viewId;

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  DaroAdInfo _createAdInfo() {
    return DaroAdInfo(
      adUnitId: widget.adUnitId,
      format: 'native',
    );
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onAdEvent') {
      final args = call.arguments as Map<dynamic, dynamic>;
      final viewId = args['viewId'] as int;
      final event = args['event'] as String;

      if (viewId != _viewId) return;

      switch (event) {
        case 'onAdLoaded':
          widget.onAdLoaded?.call(_createAdInfo());
          break;
        case 'onAdFailedToLoad':
          final errorMap = args['error'] as Map?;
          if (errorMap != null) {
            widget.onAdFailedToLoad?.call(
              DaroAdLoadError(
                code: errorMap['code'] as int,
                message: errorMap['message'] as String,
                adUnitId: widget.adUnitId,
              ),
            );
          }
          break;
        case 'onAdClicked':
          widget.onAdClicked?.call(_createAdInfo());
          break;
        case 'onAdImpression':
          widget.onAdImpression?.call(_createAdInfo());
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildPlatformView();
  }

  Widget _buildPlatformView() {
    final Map<String, dynamic> creationParams = {
      'factoryId': widget.factoryId,
      'adUnitId': widget.adUnitId,
    };

    if (Platform.isIOS) {
      return _buildIOSView(creationParams);
    } else if (Platform.isAndroid) {
      return _buildAndroidView(creationParams);
    }

    return Text('Unsupported platform: ${Platform.operatingSystem}');
  }

  Widget _buildIOSView(Map<String, dynamic> creationParams) {
    return UiKitView(
      viewType: _viewType,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
      onPlatformViewCreated: (int id) {
        setState(() {
          _viewId = id;
        });
      },
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    );
  }

  Widget _buildAndroidView(Map<String, dynamic> creationParams) {
    return PlatformViewLink(
      viewType: _viewType,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        final controller = PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: _viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () {
            params.onFocusChanged(true);
          },
        );

        controller.addOnPlatformViewCreatedListener((int id) {
          setState(() {
            _viewId = id;
          });
          params.onPlatformViewCreated(id);
        });

        return controller..create();
      },
    );
  }

  Future<void> loadAd() async {
    if (_viewId == null) {
      return;
    }

    try {
      await _channel.invokeMethod('loadAd', {
        'viewId': _viewId,
      });
    } catch (e) {
      print('Failed to load native ad: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
