// ignore_for_file: unused_element

import 'package:example/src/common/constant/config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template router_state_observer}
/// RouterStateObserver widget.
/// {@endtemplate}
class RouterStateObserver extends StatelessWidget {
  /// {@macro router_state_observer}
  const RouterStateObserver({
    required this.octopus,
    required this.errorsObserver,
    required this.child,
    super.key,
  });

  final Octopus octopus;

  final ValueListenable<List<({Object error, StackTrace stackTrace})>>
      errorsObserver;

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final biggest = constraints.biggest;
          if (biggest.longestSide < 640 || biggest.shortestSide < 320)
            return child;
          final Axis direction;
          final Size size;
          if (biggest.width > Config.maxScreenLayoutWidth ||
              biggest.width > biggest.height) {
            direction = Axis.horizontal;
            size = const Size(320, double.infinity);
          } else {
            direction = Axis.vertical;
            size = const Size(double.infinity, 320);
          }
          return Flex(
            direction: direction,
            children: <Widget>[
              Expanded(child: child),
              if (direction == Axis.horizontal)
                const VerticalDivider(width: 1, thickness: 1)
              else
                const Divider(height: 1, thickness: 1),
              SizedBox.fromSize(
                size: size,
                child: DefaultTabController(
                  initialIndex: 0,
                  length: 3,
                  child: Scaffold(
                    body: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 72,
                          child: TabBar(
                            tabs: <Widget>[
                              Tab(
                                icon: Icon(Icons.navigation),
                                text: 'State',
                              ),
                              Tab(
                                icon: Icon(Icons.history),
                                text: 'History',
                              ),
                              Tab(
                                icon: Icon(Icons.error),
                                text: 'Errors',
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            children: <Widget>[
                              _RouterStateObserver$Tree(
                                observer: octopus.stateObserver,
                              ),
                              _RouterStateObserver$History(
                                octopus: octopus,
                              ),
                              _RouterStateObserver$Errors(
                                observer: errorsObserver,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
}

class _RouterStateObserver$Tree extends StatelessWidget {
  const _RouterStateObserver$Tree({
    required this.observer,
    super.key,
  });

  final OctopusStateObserver observer;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: ValueListenableBuilder<OctopusState>(
          valueListenable: observer,
          builder: (context, state, child) => Text(
            state.toString(),
            style: const TextStyle(
              overflow: TextOverflow.clip,
              fontSize: 12,
            ),
          ),
        ),
      );
}

class _RouterStateObserver$History extends StatelessWidget {
  const _RouterStateObserver$History({
    required this.octopus,
    super.key,
  });

  final Octopus octopus;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<OctopusState>(
        valueListenable: octopus.stateObserver,
        builder: (context, state, child) {
          final history = octopus.history;
          return ListView.builder(
            /* physics: const NeverScrollableScrollPhysics(), */
            itemCount: history.length,
            itemBuilder: (context, index) {
              final state = history[index];
              final location = state.location;
              return ListTile(
                onTap: () => octopus.setState((_) => state),
                title: Text(
                  location,
                  /* style: const TextStyle(
                    overflow: TextOverflow.clip,
                    fontSize: 12,
                  ), */
                ),
              );
            },
          );
        },
      );
}

class _RouterStateObserver$Errors extends StatefulWidget {
  const _RouterStateObserver$Errors({required this.observer, super.key});

  final ValueListenable<List<({Object error, StackTrace stackTrace})>> observer;

  @override
  State<_RouterStateObserver$Errors> createState() =>
      _RouterStateObserver$ErrorsState();
}

class _RouterStateObserver$ErrorsState
    extends State<_RouterStateObserver$Errors> {
  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<List<({Object error, StackTrace stackTrace})>>(
        valueListenable: widget.observer,
        builder: (context, list, child) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final (:error, :stackTrace) = list[index];
            return ListTile(
              onTap: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    error.toString(),
                    style: const TextStyle(
                      overflow: TextOverflow.clip,
                      fontSize: 12,
                    ),
                  ),
                  content: Text(
                    stackTrace.toString(),
                    style: const TextStyle(
                      overflow: TextOverflow.clip,
                      fontSize: 12,
                    ),
                  ),
                ),
              ).ignore(),
              title: Text(
                error.toString(),
              ),
            );
          },
        ),
      );
}
