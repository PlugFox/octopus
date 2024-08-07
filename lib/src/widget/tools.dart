// ignore_for_file: cascade_invocations

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:octopus/src/controller/controller.dart';
import 'package:octopus/src/controller/observer.dart';
import 'package:octopus/src/state/state.dart';

/// {@template octopus_tools}
/// Display the Octopus tools widget.
/// Helpful for router debugging.
/// {@endtemplate}
class OctopusTools extends StatefulWidget {
  /// {@macro octopus_tools}
  const OctopusTools({
    required this.child,
    this.octopus,
    this.enable = kDebugMode,
    this.duration = const Duration(milliseconds: 250),
    super.key,
  });

  /// Enable the OctopusTools widget.
  final bool enable;

  /// The Octopus instance.
  final Octopus? octopus;

  /// Animation duration.
  final Duration duration;

  /// The child widget.
  final Widget child;

  @override
  State<OctopusTools> createState() => _OctopusToolsState();
}

class _OctopusToolsState extends State<OctopusTools>
    with SingleTickerProviderStateMixin {
  late final _OctopusToolsController _controller;
  static const double handleWidth = 16;
  bool dismissed = true;

  @override
  void initState() {
    super.initState();
    _controller = _OctopusToolsController(
      value: 0,
      duration: widget.duration,
      vsync: this,
    );
    _controller.addStatusListener(_onStatusChanged);
    _onStatusChanged(_controller.status);
  }

  @override
  void didUpdateWidget(covariant OctopusTools oldWidget) {
    if (widget.enable) {
      dismissed = _controller.status == AnimationStatus.dismissed;
    } else {
      dismissed = true;
    }
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onStatusChanged(AnimationStatus status) {
    if (!mounted) return;
    switch (status) {
      case AnimationStatus.dismissed:
        if (dismissed) return;
        setState(() => dismissed = true);
      default:
        if (!dismissed) return;
        setState(() => dismissed = false);
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  Widget _materialContext({required Widget child}) => /* AnimatedTheme */ Theme(
        data: ThemeData.dark(),
        /* duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut, */
        child: Row(
          children: <Widget>[
            // Tools
            Expanded(
              child: Visibility(
                visible: !dismissed,
                maintainState: true,
                maintainAnimation: false,
                maintainSize: false,
                maintainInteractivity: false,
                maintainSemantics: false,
                child: Material(
                  elevation: 0,
                  child: DefaultSelectionStyle(
                    child: ScaffoldMessenger(
                      child: HeroControllerScope.none(
                        child: Navigator(
                          pages: <Page<void>>[
                            MaterialPage<void>(
                              child: Scaffold(
                                body: SafeArea(
                                  child: child,
                                ),
                              ),
                            ),
                          ],
                          onDidRemovePage: (page) {},
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Handle
            SizedBox(
              width: handleWidth,
              height: 64,
              child: Material(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(16),
                ),
                elevation: 0,
                child: InkWell(
                  onTap: () => _controller.toggle(),
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(16),
                  ),
                  child: Center(
                    child: RotationTransition(
                      turns: _controller.drive(
                        Tween<double>(
                          begin: 0,
                          end: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => !widget.enable
      ? widget.child
      : LayoutBuilder(
          builder: (context, constraints) {
            final biggest = constraints.biggest;
            final width = math.min<double>(320, biggest.width * 0.85);
            return Stack(
              children: <Widget>[
                // Content
                widget.child,
                // ModalBarrier
                if (!dismissed)
                  AnimatedModalBarrier(
                    color: _controller.drive(
                      ColorTween(
                        begin: Colors.transparent,
                        end: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    dismissible: true,
                    semanticsLabel: 'Dismiss',
                    onDismiss: () => _controller.hide(),
                  ),
                // ToolBar
                PositionedTransition(
                  rect: _controller.drive(
                    RelativeRectTween(
                      begin: RelativeRect.fromLTRB(
                        handleWidth - width,
                        0,
                        biggest.width - handleWidth,
                        0,
                      ),
                      end: RelativeRect.fromLTRB(
                        0,
                        0,
                        biggest.width - width,
                        0,
                      ),
                    ),
                  ),
                  child: SizedBox(
                    width: width,
                    child: _materialContext(
                      child: DefaultTabController(
                        length: 2,
                        animationDuration: const Duration(milliseconds: 450),
                        child: _OctopusTools$Tabs(
                          octopus: widget.octopus ?? Octopus.instance,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
}

class _OctopusToolsController extends AnimationController {
  _OctopusToolsController({
    required super.vsync,
    Duration duration = const Duration(milliseconds: 250),
    super.value, // ignore: unused_element
  }) : super(
          lowerBound: 0,
          upperBound: 1,
          duration: duration,
        );

  TickerFuture show() => forward();

  TickerFuture hide() => reverse();
}

class _OctopusTools$Tabs extends StatelessWidget {
  const _OctopusTools$Tabs({
    required this.octopus,
    super.key, // ignore: unused_element
  });

  final Octopus octopus;

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 72,
            child: TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(
                    Icons.navigation,
                    color:
                        controller.index == 0 ? Colors.green : Colors.blueGrey,
                  ),
                  text: 'State',
                ),
                Tab(
                  icon: Icon(
                    Icons.history,
                    color:
                        controller.index == 1 ? Colors.blue : Colors.blueGrey,
                  ),
                  text: 'History',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _OctopusTools$Tabs$Tree(
                  observer: octopus.observer,
                ),
                _OctopusTools$Tabs$History(
                  octopus: octopus,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OctopusTools$Tabs$Tree extends StatelessWidget {
  const _OctopusTools$Tabs$Tree({
    required this.observer,
    super.key, // ignore: unused_element
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
            const _OctopusTools$Tabs$Tree$Divider('State Arguments'),
            SizedBox(
              height: math.min(128, state.arguments.length * 24 + 72),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: <Widget>[
                    for (final arg in state.arguments.entries)
                      SizedBox(
                        height: 18,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 64,
                              child: Text(
                                '${arg.key}:',
                                maxLines: 1,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                arg.value,
                                maxLines: 1,
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const _OctopusTools$Tabs$Tree$Divider('State Intention'),
            SizedBox(
              height: 24,
              child: Center(
                child: Text(
                  state.intention.name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
}

class _OctopusTools$Tabs$Tree$Divider extends StatelessWidget {
  const _OctopusTools$Tabs$Tree$Divider(
    this.label, {
    super.key, // ignore: unused_element
  });

  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            width: 24,
            child: Divider(
              height: 1,
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Divider(
              height: 1,
              thickness: 1,
            ),
          ),
        ],
      );
}

class _OctopusTools$Tabs$History extends StatefulWidget {
  const _OctopusTools$Tabs$History({
    required this.octopus,
    super.key, // ignore: unused_element
  });

  final Octopus octopus;

  @override
  State<_OctopusTools$Tabs$History> createState() =>
      _OctopusTools$Tabs$HistoryState();
}

class _OctopusTools$Tabs$HistoryState
    extends State<_OctopusTools$Tabs$History> {
  List<OctopusHistoryEntry> history = <OctopusHistoryEntry>[];
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.octopus.observer.addListener(_listener);
    history = widget.octopus.history;
  }

  @override
  void didUpdateWidget(covariant _OctopusTools$Tabs$History oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.octopus.observer.removeListener(_listener);
    widget.octopus.observer.addListener(_listener);
  }

  @override
  void dispose() {
    widget.octopus.observer.removeListener(_listener);
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
