import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template history_button}
/// HistoryButton widget.
/// {@endtemplate}
class HistoryButton extends StatefulWidget {
  /// {@macro history_button}
  const HistoryButton({
    super.key, // ignore: unused_element
  });

  @override
  State<HistoryButton> createState() => _HistoryButtonState();
}

class _HistoryButtonState extends State<HistoryButton> {
  final OverlayPortalController controller = OverlayPortalController();

  @override
  Widget build(BuildContext context) => OverlayPortal.targetsRootOverlay(
        controller: controller,
        overlayChildBuilder: overlayChildBuilder,
        child: IconButton(
          icon: const Icon(Icons.history),
          onPressed: controller.show,
        ),
      );

  Widget overlayChildBuilder(BuildContext context) => Stack(
        children: <Widget>[
          // Barrier
          Positioned.fill(
            child: ModalBarrier(
              color: Colors.black26,
              dismissible: true,
              semanticsLabel: 'History',
              barrierSemanticsDismissible: true,
              onDismiss: controller.hide,
            ),
          ),

          // Content
          Positioned(
            right: 24,
            top: 52,
            width: math.min(300, MediaQuery.of(context).size.width - 104),
            height: math.min(500, MediaQuery.of(context).size.height - 128),
            child: Align(
              alignment: Alignment.topCenter,
              child: Card(
                elevation: 8,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: _HistorySearchWidget(
                  controller: controller,
                ),
              ),
            ),
          ),
        ],
      );
}

class _HistorySearchWidget extends StatefulWidget {
  const _HistorySearchWidget({
    required this.controller,
    super.key, // ignore: unused_element
  });

  final OverlayPortalController controller;

  @override
  State<_HistorySearchWidget> createState() => _HistorySearchWidgetState();
}

typedef _Entry = (String? title, OctopusHistoryEntry entry);

class _HistorySearchWidgetState extends State<_HistorySearchWidget> {
  late final OctopusStateObserver _observer;
  final TextEditingController _controller = TextEditingController();
  late final List<_Entry> _entries;
  late List<_Entry> _filtered;

  @override
  void initState() {
    super.initState();
    final octopus = context.octopus;
    final routes = octopus.config.routerDelegate.routes;
    _observer = octopus.observer;
    _entries = _observer.history.reversed.skip(1).map((e) {
      final route = routes[e.state.children.lastOrNull?.name];
      return (route?.title, e);
    }).toList(growable: false);
    _controller.addListener(_search);
    _search();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_search)
      ..dispose();
    super.dispose();
  }

  void _select(OctopusHistoryEntry entry) {
    final router = context.octopus;
    _pop();
    Future<void>.delayed(const Duration(milliseconds: 250),
        () => router.setState((_) => entry.state));
  }

  void _pop() {
    widget.controller.hide();
  }

  void _search() {
    if (_controller.text.isEmpty) {
      _filtered = _entries.take(5).toList(growable: false);
    } else {
      final text = _controller.text.toLowerCase();
      _filtered = _entries
          .where((e) {
            final title = e.$1;
            if (title != null && title.toLowerCase().contains(text))
              return true;
            final location = e.$2.state.location;
            if (location.toLowerCase().contains(text)) return true;
            return false;
          })
          .take(5)
          .toList(growable: false);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 64,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Center(
                  child: TextField(
                    expands: false,
                    maxLines: 1,
                    controller: _controller,
                    minLines: 1,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                itemExtent: 78,
                children: <Widget>[
                  for (final entry in _filtered)
                    ListTile(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      title: Text(
                        entry.$1 ?? 'Octopus',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        entry.$2.state.location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          height: 1.5,
                        ),
                      ),
                      isThreeLine: true,
                      onTap: () => _select(entry.$2),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
}
