import 'package:example/src/common/widget/common_actions.dart';
import 'package:example/src/common/widget/scaffold_padding.dart';
import 'package:flutter/material.dart';

/// {@template picture_screen}
/// PictureScreen widget.
/// {@endtemplate}
class PictureScreen extends StatelessWidget {
  /// {@macro picture_screen}
  const PictureScreen({
    required this.id,
    super.key, // ignore: unused_element
  });

  final String? id;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Picture #$id'),
          actions: CommonActions(),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: ScaffoldPadding.of(context).copyWith(top: 16, bottom: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Material(
                  child: Hero(
                    tag: 'picture-$id',
                    child: const SizedBox(
                      height: 400,
                      child: Placeholder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
