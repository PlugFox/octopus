import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:octopus/src/state/state.dart';

/// Converts [RouteInformation] to [OctopusState] and vice versa.
class OctopusStateCodec extends Codec<RouteInformation, OctopusState> {
  /// Converts [RouteInformation] to [OctopusState] and vice versa.
  const OctopusStateCodec();

  @override
  Converter<RouteInformation, OctopusState> get encoder =>
      const OctopusStateEncoder();

  @override
  Converter<OctopusState, RouteInformation> get decoder =>
      const OctopusStateDecoder();
}

/// Converts [RouteInformation] to [OctopusState].
class OctopusStateEncoder extends Converter<RouteInformation, OctopusState> {
  /// Converts [RouteInformation] to [OctopusState].
  const OctopusStateEncoder();

  @override
  OctopusState convert(RouteInformation input) =>
      OctopusState.fromUri(input.uri);
}

/// Converts [OctopusState] to [RouteInformation].
class OctopusStateDecoder extends Converter<OctopusState, RouteInformation> {
  /// Converts [OctopusState] to [RouteInformation].
  const OctopusStateDecoder();

  @override
  RouteInformation convert(covariant OctopusState input) => RouteInformation(
        uri: input.uri,
        /* state: input, */
      );
}
