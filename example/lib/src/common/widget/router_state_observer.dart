// ignore_for_file: unused_element

import 'dart:math' as math;

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
          if (biggest.longestSide < 640 || biggest.shortestSide < 326)
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
          return Material(
            color: Theme.of(context).colorScheme.surface,
            child: Flex(
              direction: direction,
              children: <Widget>[
                // App content
                Expanded(child: child),
                // Dividers
                if (direction == Axis.horizontal) ...[
                  const VerticalDivider(width: 1, thickness: 1),
                  const SizedBox(width: 4),
                  const VerticalDivider(width: 1, thickness: 1),
                ] else ...[
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 4),
                  const Divider(height: 1, thickness: 1),
                ],
                // Router state observer
                SizedBox.fromSize(
                  size: size,
                  child: DefaultTabController(
                    initialIndex: 0,
                    length: 3,
                    child: Overlay(
                      initialEntries: [
                        OverlayEntry(
                          builder: (context) => Scaffold(
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
  Widget build(BuildContext context) => ValueListenableBuilder<OctopusState>(
        valueListenable: observer,
        builder: (context, state, child) => Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                scrollDirection: Axis.vertical,
                child: Text(
                  state.toString(),
                  style: const TextStyle(
                    overflow: TextOverflow.clip,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1),
            SizedBox(
              height: math.min(128, state.arguments.length * 24 + 64),
              child: ListView(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                children: <Widget>[
                  for (final arg in state.arguments.entries)
                    SizedBox(
                      height: 24,
                      child: Text(
                        '${arg.key}: ${arg.value}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        ),
      );
}

class _RouterStateObserver$History extends StatefulWidget {
  const _RouterStateObserver$History({
    required this.octopus,
    super.key,
  });

  final Octopus octopus;

  @override
  State<_RouterStateObserver$History> createState() =>
      _RouterStateObserver$HistoryState();
}

class _RouterStateObserver$HistoryState
    extends State<_RouterStateObserver$History> {
  List<OctopusHistoryEntry> history = <OctopusHistoryEntry>[];
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.octopus.stateObserver.addListener(_listener);
    history = widget.octopus.history;
  }

  @override
  void didUpdateWidget(covariant _RouterStateObserver$History oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.octopus.stateObserver.removeListener(_listener);
    widget.octopus.stateObserver.addListener(_listener);
  }

  @override
  void dispose() {
    widget.octopus.stateObserver.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    if (!mounted) return;
    setState(() {
      history = widget.octopus.history;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 42,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
        /* physics: const NeverScrollableScrollPhysics(), */
        controller: scrollController,
        itemCount: history.length,
        itemExtent: 24,
        scrollDirection: Axis.vertical,
        reverse: true,
        itemBuilder: (context, index) {
          final entry = history[index];
          final state = entry.state;
          final location = state.location;
          return SizedBox(
            height: 24,
            child: Tooltip(
              message: location,
              child: InkWell(
                key: ValueKey<int>(entry.hashCode),
                onTap: index == history.length - 1
                    ? null
                    : () => widget.octopus.setState((_) => state),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      height: 1,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
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
