import 'package:flutter/widgets.dart';

/// Builder for the unknown route.
typedef NotFoundBuilder = Widget Function(
  BuildContext ctx,
  String name,
  Map<String, String> arguments,
);
