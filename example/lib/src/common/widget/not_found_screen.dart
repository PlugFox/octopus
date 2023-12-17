import 'package:example/src/common/widget/common_actions.dart';
import 'package:flutter/material.dart';

/// {@template not_found}
/// NotFoundScreen widget.
/// {@endtemplate}
class NotFoundScreen extends StatelessWidget {
  /// {@macro not_found}
  const NotFoundScreen({this.title, this.message, super.key});

  final String? title;
  final String? message;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            title ?? 'Not found',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: CommonActions(),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: SizedBox(
              height: 48,
              /* child: Breadcrumbs(
              breadcrumbs: <Widget, VoidCallback?>{
                const Text('Shop'): () => AppRouter.of(context).navTab(
                      (state) => [],
                      tab: 'shop',
                      activate: true,
                    ),
                for (var i = 0; i < prevRoutes.length; i++)
                  Text(
                      ProductScope.getCategoryByID(
                              context, prevRoutes[i].arguments['id']!)
                          .title): () => AppRouter.of(context).navTab(
                        (state) => state.take(i + 1).toList(growable: false),
                        tab: 'shop',
                        activate: true,
                      ),
                const Text('Not found'): null,
              },
            ), */
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Text(message ?? 'Content not found'),
          ),
        ),
      );
}
