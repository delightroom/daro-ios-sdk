import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../internal/ad_instance_manager.dart';
import 'daro_native_ad.dart';

class DaroNativeAdWidget extends StatelessWidget {
  static const String _viewType = 'daro_native_ad_view';

  final DaroNativeAd ad;

  DaroNativeAdWidget({
    Key? key,
    required this.ad,
  }) : super(key: key ?? ValueKey(ad.adId));

  @override
  Widget build(BuildContext context) {
    if (!AdInstanceManager.instance.isReadyForView(ad.adId)) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('DaroNativeAdWidget requires ad.load() to be called before inserting into the widget tree'),
        ErrorHint('Call ad.load() and wait for onAdLoaded callback before mounting the widget.'),
      ]);
    }
    return _buildPlatformView();
  }

  Widget _buildPlatformView() {
    final Map<String, dynamic> creationParams = {
      'adId': ad.adId,
    };

    if (Platform.isIOS) {
      return UiKitView(
        viewType: _viewType,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      );
    } else if (Platform.isAndroid) {
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

          controller.addOnPlatformViewCreatedListener(params.onPlatformViewCreated);

          return controller..create();
        },
      );
    }

    return Text('Unsupported platform: ${Platform.operatingSystem}');
  }
}
