import 'dart:math' as math;

import 'package:example/src/common/widget/shimmer.dart';
import 'package:flutter/material.dart';

/// {@template text_placeholder}
/// TextPlaceholder widget.
/// {@endtemplate}
class TextPlaceholder extends StatelessWidget {
  /// {@macro text_placeholder}
  TextPlaceholder({
    double width = double.infinity,
    double height = 28,
    super.key,
  }) : size = Size(width, height);

  /// Size of the placeholder
  final Size size;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => Shimmer(
          size: Size(
            math.min(size.width, constraints.maxWidth - 16),
            size.height,
          ),
          color: Colors.grey[400],
          backgroundColor: Colors.grey[100],
        ),
      );
}
