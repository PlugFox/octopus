import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template router_state_observer}
/// RouterStateObserver widget.
/// {@endtemplate}
class RouterStateObserver extends StatelessWidget {
  /// {@macro router_state_observer}
  const RouterStateObserver(
      {required this.listenable, required this.child, super.key});

  final ValueListenable<OctopusState> listenable;

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final biggest = constraints.biggest;
          if (biggest.longestSide < 640) return child;
          final Axis direction;
          final Size size;
          if (biggest.width > biggest.height) {
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
              SizedBox.fromSize(
                size: size,
                child: Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SingleChildScrollView(
                      child: ValueListenableBuilder(
                        valueListenable: listenable,
                        builder: (context, state, child) => Text(
                          state.toString(),
                          style: const TextStyle(
                            overflow: TextOverflow.clip,
                            fontSize: 12,
                          ),
                        ),
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
