import 'package:example/src/common/widget/form_placeholder.dart';
import 'package:example/src/common/widget/scaffold_padding.dart';
import 'package:example/src/common/widget/shimmer.dart';
import 'package:example/src/feature/authentication/widget/log_out_button.dart';
import 'package:flutter/material.dart';

/// {@template profile_screen}
/// ProfileScreen widget.
/// {@endtemplate}
class ProfileScreen extends StatelessWidget {
  /// {@macro profile_screen}
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: SafeArea(
          child: ListView(
            padding: ScaffoldPadding.of(context).copyWith(top: 16, bottom: 16),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Shimmer(
                  size: const Size(128, 128),
                  color: Colors.grey[400],
                  backgroundColor: Colors.grey[100],
                  cornerRadius: 42,
                ),
              ),
              const ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(
                  'Name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1,
                  ),
                ),
                subtitle: Text(
                  'John Doe',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1,
                  ),
                ),
                trailing: LogOutButton(),
              ),
              const SizedBox(height: 24),
              const FormPlaceholder(title: false),
            ],
          ),
        ),
      );
}
