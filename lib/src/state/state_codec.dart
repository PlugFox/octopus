import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:octopus/src/state/state.dart';
import 'package:octopus/src/util/logs.dart';

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
  OctopusState convert(RouteInformation input) {
    if (input case OctopusRouteInformation octopus) return octopus.octopusState;
    try {
      if (input.state case Map<String, Object?> json) {
        return OctopusState.fromJson(json);
      }
    } on Object catch (error) {
      warning('Failed to decode state: $error');
    }
    return OctopusState.fromUri(input.uri);
  }
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
      OctopusRouteInformation(input);
}

/// A piece of routing information.
///
/// The route information consists of a location string of the application and
/// a state object that configures the application in that location.
///
/// {@nodoc}
@internal
@immutable
class OctopusRouteInformation implements RouteInformation {
  /// {@nodoc}
  OctopusRouteInformation(this.octopusState);

  /// Router state.
  final OctopusState octopusState;

  @override
  late final String location = octopusState.location;

  /// Uri of the route.
  @override
  late final Uri uri = octopusState.uri;

  /// State of the route.
  @override
  late final Object? state = octopusState.toJson();

  /// Intention for [RouteInformationProvider]
  OctopusStateIntention get intention => octopusState.intention;

  @override
  late final int hashCode = octopusState.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OctopusRouteInformation && octopusState == other.octopusState;
}
