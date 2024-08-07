import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/state/state_codec.dart';

/// Converts between [RouteInformation] and [OctopusState].
@internal
class OctopusInformationParser implements RouteInformationParser<OctopusState> {
  OctopusInformationParser({Codec<RouteInformation, OctopusState>? codec})
      : _codec = codec ?? const OctopusStateCodec();

  final Codec<RouteInformation, OctopusState> _codec;

  @override
  Future<OctopusState> parseRouteInformationWithDependencies(
    RouteInformation routeInformation,
    BuildContext context,
  ) =>
      parseRouteInformation(routeInformation);

  @override
  Future<OctopusState> parseRouteInformation(RouteInformation route) =>
      SynchronousFuture<OctopusState>(_codec.encode(route));

  @override
  RouteInformation? restoreRouteInformation(OctopusState state) =>
      _codec.decode(state);
}
