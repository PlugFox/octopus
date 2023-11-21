import 'package:flutter/material.dart';

/// {@template gallery_screen}
/// GalleryScreen widget.
/// {@endtemplate}
class GalleryScreen extends StatelessWidget {
  /// {@macro gallery_screen}
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Gallery'),
        ),
        body: const SafeArea(
          child: Center(
            child: Text('Gallery'),
          ),
        ),
      );
}
