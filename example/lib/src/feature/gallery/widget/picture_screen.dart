import 'package:example/src/common/widget/scaffold_padding.dart';
import 'package:flutter/material.dart';

/// {@template picture_screen}
/// PictureScreen widget.
/// {@endtemplate}
class PictureScreen extends StatelessWidget {
  /// {@macro picture_screen}
  const PictureScreen({
    super.key, // ignore: unused_element
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Picture'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: ScaffoldPadding.of(context),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Hero(
                  tag: 'picture-1',
                  child: SizedBox(height: 400, child: Placeholder()),
                ),
              ],
            ),
          ),
        ),
      );
}
