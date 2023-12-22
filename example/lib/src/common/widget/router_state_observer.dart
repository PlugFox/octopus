// ignore_for_file: unused_element

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template router_state_observer}
/// RouterStateObserver widget.
/// {@endtemplate}
class RouterStateObserver extends StatefulWidget {
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
  State<RouterStateObserver> createState() => _RouterStateObserverState();
}

class _RouterStateObserverState extends State<RouterStateObserver> {
  static const routerToolsSize = 326.0;
  bool _showOctopusTools = true;

  void toogle() => setState(() => _showOctopusTools = !_showOctopusTools);

  @override
  Widget build(BuildContext context) {
    final biggest = MediaQuery.sizeOf(context);
    if (biggest.longestSide < routerToolsSize * 2 ||
        biggest.shortestSide < routerToolsSize) return widget.child;

    final bool isHorizontal;
    final double contentWidth, contentHeight, toolsWidth, toolsHeight;
    if (_showOctopusTools) {
      isHorizontal = biggest.width >= biggest.height;
      toolsWidth = isHorizontal ? routerToolsSize : biggest.width;
      toolsHeight = isHorizontal ? biggest.height : routerToolsSize;
      contentWidth = isHorizontal ? biggest.width - toolsWidth : biggest.width;
      contentHeight =
          isHorizontal ? biggest.height : biggest.height - toolsHeight;
    } else {
      isHorizontal = true;
      toolsWidth = 0;
      toolsHeight = 0;
      contentWidth = biggest.width;
      contentHeight = biggest.height;
    }

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Stack(
        children: <Widget>[
          // App content
          Positioned(
            top: 0,
            left: 0,
            width: contentWidth,
            height: contentHeight,
            child: _RouterStateObserver$Content(child: widget.child),
          ),

          // Router state observer
          if (_showOctopusTools)
            Positioned(
              right: 0,
              bottom: 0,
              width: toolsWidth,
              height: toolsHeight,
              child: Theme(
                data: ThemeData.dark(),
                child: Material(
                  child: Flex(
                    direction: isHorizontal ? Axis.horizontal : Axis.vertical,
                    children: <Widget>[
                      // Dividers
                      if (isHorizontal) ...[
                        const VerticalDivider(width: 1, thickness: 1),
                        const SizedBox(width: 4),
                        const VerticalDivider(width: 1, thickness: 1),
                      ] else ...[
                        const Divider(height: 1, thickness: 1),
                        const SizedBox(height: 4),
                        const Divider(height: 1, thickness: 1),
                      ],
                      // Dev tools
                      SizedBox(
                        width: isHorizontal
                            ? routerToolsSize - 6
                            : double.infinity,
                        height: isHorizontal
                            ? double.infinity
                            : routerToolsSize - 6,
                        child: DefaultTabController(
                          initialIndex: 0,
                          length: 3,
                          child: Overlay(
                            initialEntries: <OverlayEntry>[
                              OverlayEntry(
                                builder: (context) => DefaultTabController(
                                  length: 3,
                                  animationDuration:
                                      const Duration(milliseconds: 450),
                                  child: Builder(builder: (context) {
                                    final controller =
                                        DefaultTabController.of(context);
                                    return AnimatedBuilder(
                                      animation: controller,
                                      builder: (context, child) => Column(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 72,
                                            child: TabBar(
                                              tabs: <Widget>[
                                                Tab(
                                                  icon: Icon(
                                                    Icons.navigation,
                                                    color: controller.index == 0
                                                        ? Colors.green
                                                        : Colors.blueGrey,
                                                  ),
                                                  text: 'State',
                                                ),
                                                Tab(
                                                  icon: Icon(
                                                    Icons.history,
                                                    color: controller.index == 1
                                                        ? Colors.blue
                                                        : Colors.blueGrey,
                                                  ),
                                                  text: 'History',
                                                ),
                                                Tab(
                                                  icon: Icon(
                                                    Icons.error,
                                                    color: controller.index == 2
                                                        ? Colors.red
                                                        : Colors.blueGrey,
                                                  ),
                                                  text: 'Errors',
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: TabBarView(
                                              children: <Widget>[
                                                _RouterStateObserver$Tree(
                                                  observer: widget
                                                      .octopus.stateObserver,
                                                ),
                                                _RouterStateObserver$History(
                                                  octopus: widget.octopus,
                                                ),
                                                _RouterStateObserver$Errors(
                                                  observer:
                                                      widget.errorsObserver,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
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
            ),

          // Show/hide button
          Positioned(
            key: const ValueKey<String>('ToggleOctopusTools'),
            bottom: 8,
            right: 8,
            width: 48,
            height: 48,
            child: IconButton.filled(
              color: Theme.of(context).colorScheme.surface,
              icon: Icon(
                _showOctopusTools ? Icons.close : Icons.menu,
                key: ValueKey<bool>(_showOctopusTools),
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: toogle,
            ),
          ),
        ],
      ),
    );
  }
}

class _RouterStateObserver$Content extends StatelessWidget {
  const _RouterStateObserver$Content({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: constraints.biggest,
          ),
          child: child,
        ),
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
                  SizedBox(
                    height: 24,
                    child: Text(
                      'Intention: ${state.intention.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
