import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:octopus/src/state/state.dart';

/// Converts [RouteInformation] to [OctopusState] and vice versa.
///
/// {@nodoc}
class OctopusStateCodec extends Codec<RouteInformation, OctopusState> {
  /// Converts [RouteInformation] to [OctopusState] and vice versa.
  ///
  /// {@nodoc}
  const OctopusStateCodec();

  @override
  Converter<RouteInformation, OctopusState> get encoder =>
      const OctopusStateEncoder();

  @override
  Converter<OctopusState, RouteInformation> get decoder =>
      const OctopusStateDecoder();
}

/// Converts [RouteInformation] to [OctopusState].
///
/// {@nodoc}
class OctopusStateEncoder extends Converter<RouteInformation, OctopusState> {
  /// Converts [RouteInformation] to [OctopusState].
  ///
  /// {@nodoc}
  const OctopusStateEncoder();

  @override
  OctopusState convert(RouteInformation input) =>
      OctopusState.fromUri(input.uri);
}

/// Converts [OctopusState] to [RouteInformation].
///
/// {@nodoc}
class OctopusStateDecoder extends Converter<OctopusState, RouteInformation> {
  /// Converts [OctopusState] to [RouteInformation].
  ///
  /// {@nodoc}
  const OctopusStateDecoder();

  @override
  RouteInformation convert(covariant OctopusState input) =>
      OctopusRouteInformation(
        uri: input.uri,
        /* state: input, */
      );
}

/// {@nodoc}
class OctopusRouteInformation extends RouteInformation {
  /// {@nodoc}
  const OctopusRouteInformation({
    required super.uri,
    super.state,
  });
}
