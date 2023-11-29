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
        body: SafeArea(
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 152,
              //mainAxisExtent: 180,
              childAspectRatio: 152 / 180,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: 1000,
            itemBuilder: (context, index) => _GalleryTile(index),
          ),
        ),
      );
}

class _GalleryTile extends StatelessWidget {
  // ignore: unused_element
  const _GalleryTile(this.index, {super.key});

  final int index;

  @override
  Widget build(BuildContext context) => Card(
        color: const Color(0xFFcfd8dc),
        margin: EdgeInsets.zero,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Placeholder(),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 36,
                child: Center(
                  child: Text(
                    'Item\n$index',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
