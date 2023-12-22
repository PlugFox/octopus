import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// Used for creating a dialog route if route name end with '-dialog'.
/// {@nodoc}
@internal
class OctopusDialogPage extends Page<Object?> {
  const OctopusDialogPage({
    required this.builder,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final WidgetBuilder builder;

/*   @override
  Route<void> createRoute(BuildContext context) => DialogRoute(
        context: context,
        builder: builder,
        settings: this,
      ); */

  @override
  Route<void> createRoute(BuildContext context) => MaterialPageRoute(
        /* context: context, */
        builder: builder,
        settings: this,
      );
}
