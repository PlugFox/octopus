import 'package:example/src/common/router/routes.dart';
import 'package:example/src/common/widget/common_actions.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template home_screen}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatelessWidget {
  /// {@macro home_screen}
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          leading: const SizedBox.shrink(),
          actions: CommonActions(),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              ListTile(
                title: const Text('Gallery'),
                subtitle: const Text('Simple navigation between screens'),
                onTap: () => context.octopus.push(Routes.gallery),
              ),
              ListTile(
                title: const Text('Shop'),
                subtitle: const Text('Explore nested navigation'),
                onTap: () => context.octopus.push(Routes.shop),
              ),
              ListTile(
                title: const Text('Profile'),
                subtitle: const Text('Profile with dialogs & anonymous routes'),
                onTap: () => context.octopus.push(Routes.profile),
              ),
              const _ShowDialogExample(),
            ],
          ),
        ),
      );
}

class _ShowDialogExample extends StatefulWidget {
  const _ShowDialogExample({
    super.key, // ignore: unused_element
  });

  @override
  State<_ShowDialogExample> createState() => _ShowDialogExampleState();
}

class _ShowDialogExampleState extends State<_ShowDialogExample> {
  String? lastResult;

  @override
  Widget build(BuildContext context) => ListTile(
        title: const Text('Show dialog'),
        subtitle: Text(switch (lastResult) {
          String text when text.isNotEmpty => 'Last result: $text',
          _ => 'Show dialog and receive result',
        }),
        onTap: () => context.octopus
            .showDialog<String>((context) => const _DialogExample())
            .then<void>((value) => setState(() => lastResult = value)),
      );
}

class _DialogExample extends StatefulWidget {
  const _DialogExample({
    super.key, // ignore: unused_element
  });

  @override
  State<_DialogExample> createState() => _DialogExampleState();
}

class _DialogExampleState extends State<_DialogExample> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog.adaptive(
        title: const Text('Dialog example'),
        alignment: Alignment.center,
        scrollable: false,
        content: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 200,
                height: 64,
                child: TextField(
                  controller: _controller,
                  decoration:
                      const InputDecoration(hintText: 'Enter some text'),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    ),
                    child: value.text.isEmpty
                        ? const Icon(Icons.close, key: Key('close'))
                        : const Icon(Icons.send, key: Key('send')),
                  ),
                ),
                iconSize: 32,
                onPressed: () => Navigator.maybePop(context, _controller.text),
              ),
            ],
          ),
        ),
      );
}
