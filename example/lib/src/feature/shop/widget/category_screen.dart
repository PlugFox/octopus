import 'package:example/src/common/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template category_screen}
/// CategoryScreen.
/// {@endtemplate}
class CategoryScreen extends StatelessWidget {
  /// {@macro category_screen}
  const CategoryScreen({required this.id, super.key});

  final String? id;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              title: Text('Category#$id'),
              pinned: true,
              floating: true,
              snap: true,
              /* expandedHeight: 200,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  'https://picsum.photos/seed/$id/600/200',
                  fit: BoxFit.cover,
                ),
              ), */
            ),

            // Subcategories
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final categoryId = '$id-$index';
                  return ListTile(
                    title: Text('Category#$categoryId'),
                    onTap: () {
                      Octopus.push(
                        context,
                        Routes.category,
                        arguments: <String, String>{'id': categoryId},
                      );
                    },
                  );
                },
                childCount: 100,
              ),
            ),

            // Divider
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: Divider(
                  height: 1,
                  thickness: 1,
                ),
              ),
            ),

            // Products
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final categoryId = '$id-$index';
                  return ListTile(
                    title: Text('Product#$categoryId'),
                    onTap: () {
                      Octopus.push(
                        context,
                        Routes.product,
                        arguments: <String, String>{'id': categoryId},
                      );
                    },
                  );
                },
                childCount: 100,
              ),
            ),
          ],
        ),
      );
}
