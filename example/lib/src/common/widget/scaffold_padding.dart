import 'dart:math' as math;

import 'package:example/src/common/constant/config.dart';
import 'package:flutter/material.dart';

/// {@template scaffold_padding}
/// ScaffoldPadding widget.
/// {@endtemplate}
class ScaffoldPadding extends EdgeInsets {
  const ScaffoldPadding._(final double value)
      : super.symmetric(horizontal: value);

  /// {@macro scaffold_padding}
  factory ScaffoldPadding.of(BuildContext context) =>
      ScaffoldPadding._(math.max(
          (MediaQuery.sizeOf(context).width - Config.maxScreenLayoutWidth) / 2,
          16));

  /// {@macro scaffold_padding}
  static Widget widget(BuildContext context, [Widget? child]) =>
      Padding(padding: ScaffoldPadding.of(context), child: child);

  /// {@macro scaffold_padding}
  static Widget sliver(BuildContext context, [Widget? child]) =>
      SliverPadding(padding: ScaffoldPadding.of(context), sliver: child);
}
