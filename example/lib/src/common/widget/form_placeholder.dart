import 'package:example/src/common/widget/shimmer.dart';
import 'package:example/src/common/widget/text_placeholder.dart';
import 'package:flutter/material.dart';

/// {@template form_placeholder}
/// FormPlaceholder widget.
/// {@endtemplate}
class FormPlaceholder extends StatelessWidget {
  /// {@macro form_placeholder}
  const FormPlaceholder({
    this.title = false,
    super.key,
  });

  final bool title;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          if (title)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Shimmer(
                size: const Size(64, 64),
                color: Colors.grey[400],
                backgroundColor: Colors.grey[100],
                cornerRadius: 24,
              ),
            ),
          const SizedBox(height: 16),
          TextPlaceholder(width: 152),
          const SizedBox(height: 16),
          TextPlaceholder(width: 256),
          const SizedBox(height: 16),
          TextPlaceholder(width: 128),
          const SizedBox(height: 16),
          TextPlaceholder(width: 64),
          const SizedBox(height: 16),
          TextPlaceholder(width: 256),
          const SizedBox(height: 16),
          TextPlaceholder(width: 512),
          const SizedBox(height: 16),
          TextPlaceholder(width: 256),
          const SizedBox(height: 16),
          TextPlaceholder(width: 128),
        ],
      );
}
