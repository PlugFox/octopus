import 'package:example/src/common/constant/pubspec.yaml.g.dart';
import 'package:example/src/common/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template about_app_dialog}
/// AboutApplicationDialog widget.
/// {@endtemplate}
class AboutApplicationDialog extends StatelessWidget {
  /// {@macro about_app_dialog}
  const AboutApplicationDialog({super.key});

  @override
  Widget build(BuildContext context) => AboutDialog(
        applicationName: Pubspec.name,
        applicationVersion: Pubspec.version.representation,
        applicationIcon: const SizedBox.square(
          dimension: 64,
          child: CircleAvatar(
            child: Icon(Icons.apps),
          ),
        ),
        children: <Widget>[
          const _AboutApplicationDialog$Tile(
            title: 'Name',
            subtitle: Pubspec.name,
            content: Pubspec.name,
          ),
          _AboutApplicationDialog$Tile(
            title: 'Version',
            subtitle: Pubspec.version.representation,
            content: Pubspec.version.representation,
          ),
          const _AboutApplicationDialog$Tile(
            title: 'Description',
            subtitle: Pubspec.description,
            content: Pubspec.description,
          ),
          const _AboutApplicationDialog$Tile(
            title: 'Homepage',
            subtitle: Pubspec.homepage,
            content: Pubspec.homepage,
          ),
          const _AboutApplicationDialog$Tile(
            title: 'Repository',
            subtitle: Pubspec.repository,
            content: Pubspec.repository,
          ),
        ],
      );
}

class _AboutApplicationDialog$Tile extends StatelessWidget {
  const _AboutApplicationDialog$Tile(
      {required this.title, this.subtitle, this.content});

  final String title;
  final String? subtitle;
  final String? content;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 72,
        child: ListTile(
          title: Text(title),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          isThreeLine: false,
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          onTap: () {
            Clipboard.setData(ClipboardData(
                text: content ??
                    (subtitle == null ? title : '$title: $subtitle')));
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(SnackBar(
                  content: Text(Localization.of(context).copied),
                  duration: const Duration(seconds: 3)));
            HapticFeedback.lightImpact();
          },
        ),
      );
}
