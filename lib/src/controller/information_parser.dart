import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/state/state_codec.dart';

/// Converts between [RouteInformation] and [OctopusState].
/// {@nodoc}
@internal
class OctopusInformationParser implements RouteInformationParser<OctopusState> {
  /// {@nodoc}
  OctopusInformationParser() : _codec = const OctopusStateCodec();

  final OctopusStateCodec _codec;

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
