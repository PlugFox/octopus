import 'package:example/src/common/router/routes.dart';
import 'package:example/src/common/widget/form_placeholder.dart';
import 'package:example/src/common/widget/scaffold_padding.dart';
import 'package:example/src/common/widget/shimmer.dart';
import 'package:example/src/common/widget/text_placeholder.dart';
import 'package:example/src/feature/authentication/widget/log_out_button.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template profile_screen}
/// ProfileScreen widget.
/// {@endtemplate}
class ProfileScreen extends StatelessWidget {
  /// {@macro profile_screen}
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            const SliverAppBar(
              title: Text('Profile'),
              pinned: true,
              floating: true,
              snap: true,
            ),
            SliverPadding(
              padding:
                  ScaffoldPadding.of(context).copyWith(top: 16, bottom: 16),
              sliver: SliverList.list(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Shimmer(
                          size: const Size(128, 128),
                          color: Colors.grey[400],
                          backgroundColor: Colors.grey[100],
                          cornerRadius: 42,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextPlaceholder(height: 16, width: 64),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: TextPlaceholder(height: 14, width: 100),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: TextPlaceholder(height: 14, width: 128),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: TextPlaceholder(height: 14, width: 72),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: TextPlaceholder(height: 14, width: 92),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 68,
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      isThreeLine: false,
                      title: const Text(
                        'Name',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1,
                        ),
                      ),
                      subtitle: const Text(
                        'John Doe',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 1,
                        ),
                      ),
                      trailing: const LogOutButton(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 68,
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.settings)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      isThreeLine: false,
                      title: const Text(
                        'Settings',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1,
                        ),
                      ),
                      subtitle: const Text(
                        'Change your settings',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 1,
                        ),
                      ),
                      onTap: () => context.octopus.push(Routes.settingsDialog),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    height: 68,
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.info)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      isThreeLine: false,
                      title: const Text(
                        'About',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          height: 1,
                        ),
                      ),
                      subtitle: const Text(
                        'Information about the application',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 1,
                        ),
                      ),
                      onTap: () => context.octopus.push(Routes.aboutAppDialog),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const FormPlaceholder(title: false),
                ],
              ),
            ),
          ],
        ),
      );
}
