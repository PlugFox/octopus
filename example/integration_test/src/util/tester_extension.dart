import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data' as td;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart' show WidgetsApp;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

extension WidgetTesterExtension on WidgetTester {
  /// Sleep for `duration`.
  Future<void> sleep([Duration duration = const Duration(milliseconds: 500)]) =>
      Future<void>.delayed(duration);

  /// Pump the widget tree, wait and then pumps a frame again.
  Future<void> pumpAndPause([
    Duration duration = const Duration(milliseconds: 500),
  ]) async {
    await pump();
    await sleep(duration);
    await pump();
  }

  /// Try to pump and find some widget few times.
  Future<Finder> asyncFinder({
    required Finder Function() finder,
    Duration limit = const Duration(milliseconds: 15000),
  }) async {
    final stopwatch = Stopwatch()..start();
    var result = finder();
    try {
      while (stopwatch.elapsed <= limit) {
        await pumpAndSettle(const Duration(milliseconds: 100))
            .timeout(limit - stopwatch.elapsed);
        result = finder();
        if (result.evaluate().isNotEmpty) return result;
      }
      return result;
    } on TimeoutException {
      return result;
    } on Object {
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  /// Returns a function that takes a screenshot of the current state of the app.
  Future<List<int>> Function([String? name]) screenshot({
    /// The [_$pixelRatio] describes the scale between the logical pixels and the
    /// size of the output image. It is independent of the
    /// [dart:ui.FlutterView.devicePixelRatio] for the device, so specifying 1.0
    /// (the default) will give you a 1:1 mapping between logical pixels and the
    /// output pixels in the image.
    double pixelRatio = 1,

    /// If provided, the screenshot will be get
    /// with standard [IntegrationTestWidgetsFlutterBinding.takeScreenshot] on
    /// Android and iOS devices.
    IntegrationTestWidgetsFlutterBinding? binding,
  }) =>
      ([name]) async {
        await pump();
        if (binding != null &&
            name != null &&
            (io.Platform.isAndroid || io.Platform.isIOS)) {
          if (io.Platform.isAndroid)
            await binding.convertFlutterSurfaceToImage();
          return await binding.takeScreenshot(name);
        } else {
          final element = firstElement(find.byType(WidgetsApp));
          RenderRepaintBoundary? boundary;
          element.visitAncestorElements((element) {
            final renderObject = element.renderObject;
            if (renderObject is RenderRepaintBoundary) boundary = renderObject;
            return true;
          });
          if (boundary == null)
            throw StateError('No RenderRepaintBoundary found');
          final image = await boundary!.toImage(pixelRatio: pixelRatio);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          if (bytes is! td.ByteData)
            throw StateError('Error converting image to bytes');
          return bytes.buffer.asUint8List();
        }
      };
}
