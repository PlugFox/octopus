import 'package:example/src/common/router/routes.dart';
import 'package:example/src/common/widget/scaffold_padding.dart';
import 'package:example/src/feature/shop/widget/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template catalog_tab}
/// CatalogTab widget.
/// {@endtemplate}
class CatalogTab extends StatelessWidget {
  /// {@macro catalog_tab}
  const CatalogTab({super.key});

  @override
  Widget build(BuildContext context) => OctopusNavigator.nested(
        bucket: '${ShopTabsEnum.catalog.value}-tab',
        defaultRoute: Routes.catalog,
      );
}

/// {@template catalog_screen}
/// CatalogScreen widget.
/// {@endtemplate}
class CatalogScreen extends StatelessWidget {
  /// {@macro catalog_screen}
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Catalog'),
          leading: BackButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.maybePop(context);
                return;
              }
              // On back button pressed, close shop tabs
              Octopus.of(context).setState(
                (state) => state
                  ..removeWhere(
                    (route) => route.name == Routes.shop.name,
                  ),
              );
            },
          ),
        ),
        body: SafeArea(
          child: GridView.builder(
            padding: ScaffoldPadding.of(context),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 152,
              //mainAxisExtent: 180,
              childAspectRatio: 152 / 180,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 1000,
            itemBuilder: (context, index) {
              final id = index;
              return _CatalogTile(id: id, key: ValueKey(id));
            },
          ),
        ),
      );
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context) => Card(
        color: const Color(0xFFcfd8dc),
        margin: EdgeInsets.zero,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Octopus.push(
              context,
              Routes.category,
              arguments: <String, String>{'id': '$id'},
            );
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Ink(
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
                      'Id#$id',
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
        ),
      );
}
