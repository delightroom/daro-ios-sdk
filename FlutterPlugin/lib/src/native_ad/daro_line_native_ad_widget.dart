import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../models/daro_ad_info.dart';
import '../models/daro_ad_load_error.dart';

class DaroLineNativeAdStyle {
  final String? backgroundColor;
  final String? contentColor;
  final String? adMarkLabelTextColor;
  final String? adMarkLabelBackgroundColor;

  const DaroLineNativeAdStyle({
    this.backgroundColor,
    this.contentColor,
    this.adMarkLabelTextColor,
    this.adMarkLabelBackgroundColor,
  });

  Map<String, dynamic> toMap() {
    return {
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      if (contentColor != null) 'contentColor': contentColor,
      if (adMarkLabelTextColor != null) 'adMarkLabelTextColor': adMarkLabelTextColor,
      if (adMarkLabelBackgroundColor != null) 'adMarkLabelBackgroundColor': adMarkLabelBackgroundColor,
    };
  }
}

class DaroLineNativeAdWidget extends StatefulWidget {
  final String adUnitId;
  final DaroLineNativeAdStyle style;
  final void Function(DaroAdInfo adInfo)? onAdLoaded;
  final void Function(DaroAdLoadError error)? onAdFailedToLoad;
  final void Function(DaroAdInfo adInfo)? onAdClicked;
  final void Function(DaroAdInfo adInfo)? onAdImpression;

  const DaroLineNativeAdWidget({
    Key? key,
    required this.adUnitId,
    this.style = const DaroLineNativeAdStyle(),
    this.onAdLoaded,
    this.onAdFailedToLoad,
    this.onAdClicked,
    this.onAdImpression,
  }) : super(key: key);

  @override
  State<DaroLineNativeAdWidget> createState() => DaroLineNativeAdWidgetState();

  static DaroLineNativeAdWidgetState? of(BuildContext context) {
    return context.findAncestorStateOfType<DaroLineNativeAdWidgetState>();
  }
}

class DaroLineNativeAdWidgetState extends State<DaroLineNativeAdWidget> {
  static const String _viewType = 'daro_line_native_ad_view';
  static const MethodChannel _channel = MethodChannel('daro_flutter/line_native_ad');

  int? _viewId;

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  DaroAdInfo _createAdInfo() {
    return DaroAdInfo(
      adUnitId: widget.adUnitId,
      format: 'line_native',
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
                code: errorMap['code'] as int? ?? -1,
                message: errorMap['message'] as String? ?? 'Unknown error',
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
      'adUnitId': widget.adUnitId,
      ...widget.style.toMap(),
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
      debugPrint('Failed to load line native ad: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
