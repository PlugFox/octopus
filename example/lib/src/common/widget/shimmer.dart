import 'dart:ui' as ui show FragmentProgram, FragmentShader;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// {@template shimmer}
/// A widget that creates a shimmering effect similar
/// to a moving highlight or reflection.
/// This is commonly used as a placeholder or loading indicator.
/// {@endtemplate}
/// {@category shaders}
class Shimmer extends StatefulWidget {
  /// {@macro shimmer}
  const Shimmer({
    this.color,
    this.backgroundColor,
    this.speed = 15,
    this.stripeWidth = .2,
    this.size = const Size(128, 28),
    this.cornerRadius = 8,
    this.initialSeed = .0,
    super.key,
  });

  /// The color used for the shimmering effect,
  /// usually a light color for contrast.
  /// If not specified, defaults to the color
  /// set in the current theme's `ColorScheme.onSurface`.
  final Color? color;

  /// The color of the widget's background.
  /// Should typically contrast with [color].
  /// If not specified, defaults to the color
  /// set in the current theme's `ColorScheme.surface`.
  final Color? backgroundColor;

  /// The radius of the corners of the widget in logical pixels.
  /// Defaults to 8 logical pixels.
  final double cornerRadius;

  /// The speed of the shimmering effect, in logical pixels per second.
  /// Defaults to 0.015.
  final double speed;

  /// The width of the stripes in the shimmering effect,
  /// expressed as a fraction of the widget's width.
  /// Defaults to 0.1, meaning each stripe will be 1/10th of the widget's width.
  final double stripeWidth;

  /// The size of the widget in logical pixels.
  /// Defaults to a size of 128 logical pixels wide and 28 logical pixels tall.
  final Size size;

  /// The initial offset of the shimmering effect.
  /// Expressed as a fraction of the widget's width.
  /// Defaults to 0.0,
  /// meaning the shimmering effect starts at the leading edge of the widget.
  final double initialSeed;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  /// Init shader.
  static final Future<ui.FragmentShader?> _shaderFuture =
      ui.FragmentProgram.fromAsset('assets/shaders/shimmer.frag')
          .then<ui.FragmentShader?>((program) => program.fragmentShader(),
              onError: (_, __) => null);

  /// Seed value notifier for shader mutation.
  late final ValueNotifier<double> _seed;

  /// Animated ticker.
  late final Ticker _ticker;

  void _updateSeed(Duration elapsed) =>
      _seed.value = elapsed.inMilliseconds * widget.speed / 8000;

  @override
  void initState() {
    super.initState();
    _seed = ValueNotifier<double>(widget.initialSeed);
    _ticker = createTicker(_updateSeed)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _seed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: SizedBox.fromSize(
          size: widget.size,
          child: RepaintBoundary(
            child: FutureBuilder<ui.FragmentShader?>(
              initialData: null,
              future: _shaderFuture,
              builder: (context, snapshot) => CustomPaint(
                size: widget.size,
                painter: _ShimmerPainter(
                  shader: snapshot.data,
                  seed: _seed,
                  /* ?? Colors.grey */
                  color: widget.color ?? Theme.of(context).colorScheme.primary,
                  /* ?? Theme.of(context).colorScheme.surface */
                  backgroundColor: widget.backgroundColor ??
                      Theme.of(context).colorScheme.background,
                  cornerRadius: widget.cornerRadius,
                  stripeWidth: widget.stripeWidth,
                ),
              ),
            ),
          ),
        ),
      );
}

class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter({
    required this.seed,
    required this.color,
    required this.backgroundColor,
    required this.stripeWidth,
    required this.cornerRadius,
    required this.shader,
  }) : super(repaint: seed);

  final ValueListenable<double> seed;
  final Color color;
  final Color backgroundColor;
  final double stripeWidth;
  final double cornerRadius;
  final ui.FragmentShader? shader;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (shader == null)
      return canvas.drawRect(rect, Paint()..color = backgroundColor);
    final paint = Paint()
      ..shader = (shader!
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, seed.value)
        ..setFloat(3, color.red / 255)
        ..setFloat(4, color.green / 255)
        ..setFloat(5, color.blue / 255)
        ..setFloat(6, color.alpha / 255)
        ..setFloat(7, backgroundColor.red / 255)
        ..setFloat(8, backgroundColor.green / 255)
        ..setFloat(9, backgroundColor.blue / 255)
        ..setFloat(10, backgroundColor.alpha / 255)
        ..setFloat(11, stripeWidth));
    canvas
      ..clipRRect(RRect.fromRectAndRadius(rect, Radius.circular(cornerRadius)))
      ..drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter oldDelegate) =>
      color != oldDelegate.color ||
      backgroundColor != oldDelegate.backgroundColor ||
      cornerRadius != oldDelegate.cornerRadius ||
      stripeWidth != oldDelegate.stripeWidth;
}
