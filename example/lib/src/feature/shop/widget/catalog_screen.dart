import 'dart:async';

import 'package:example/src/common/router/routes.dart';
import 'package:example/src/common/util/color_util.dart';
import 'package:example/src/common/widget/common_actions.dart';
import 'package:example/src/common/widget/scaffold_padding.dart';
import 'package:example/src/feature/shop/model/category.dart';
import 'package:example/src/feature/shop/model/product.dart';
import 'package:example/src/feature/shop/widget/category_screen.dart';
import 'package:example/src/feature/shop/widget/shop_back_button.dart';
import 'package:example/src/feature/shop/widget/shop_scope.dart';
import 'package:example/src/feature/shop/widget/shop_screen.dart';
import 'package:flutter/foundation.dart';
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
  Widget build(BuildContext context) {
    final categories = ShopScope.getRootCategories(context);
    final colors = ColorUtil.getColors(categories.length);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          // App bar
          SliverAppBar(
            title: const Text('Catalog'),
            leading: const ShopBackButton(),
            actions: CommonActions(),
            floating: true,
            snap: true,
          ),

          /// Top padding
          const SliverPadding(
            padding: EdgeInsets.only(top: 16),
          ),

          const _CatalogDivider('Categories'),

          // Catalog root categories
          SliverPadding(
            padding: ScaffoldPadding.of(context),
            sliver: SliverFixedExtentList.list(
              itemExtent: 84,
              children: <Widget>[
                for (var i = 0; i < categories.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _CatalogTile(
                      categories[i],
                      color: colors[i],
                      key: ValueKey<CategoryID>(categories[i].id),
                    ),
                  ),
              ],
            ),
          ),

          const _CatalogDivider('Recently viewed products'),
          const _RecentlyViewedProducts(),

          /// Bottom padding
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 16),
          ),
        ],
      ),
    );
  }
}

class _CatalogDivider extends StatelessWidget {
  const _CatalogDivider(
    this.title, {
    super.key, // ignore: unused_element
  });

  final String title;

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: ScaffoldPadding.of(context).copyWith(top: 16, bottom: 16),
        sliver: SliverToBoxAdapter(
          child: SizedBox(
            height: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                const Expanded(flex: 1, child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      height: 1,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Expanded(flex: 9, child: Divider()),
              ],
            ),
          ),
        ),
      );
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile(
    this.category, {
    this.color,
    super.key,
  });

  final CategoryEntity category;
  final Color? color;

  static final Map<CategoryID, IconData> _icons = <CategoryID, IconData>{
    'electronics': Icons.computer,
    'fragrances': Icons.spa,
    'groceries': Icons.shopping_cart,
    'home-decoration': Icons.home,
    'skincare': Icons.face,
  };

  @override
  Widget build(BuildContext context) => ListTile(
        dense: false,
        isThreeLine: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        iconColor: color,
        leading: AspectRatio(
          aspectRatio: 1,
          child: Ink(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(_icons[category.id] ?? Icons.category),
            ),
          ),
        ),
        title: Text(
          category.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Text(
          'Description of ${category.title}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () => Octopus.push(
          context,
          Routes.category,
          arguments: <String, String>{'id': category.id},
        ),
        /* onTap: () => Octopus.of(context).setState(
          (state) => state
            ..add(Routes.category.node(
              arguments: <String, String>{'id': category.id},
            )),
        ), */
      );
}

/// Recently viewed products from the history stack
class _RecentlyViewedProducts extends StatefulWidget {
  // ignore: unused_element
  const _RecentlyViewedProducts({this.count = 10, super.key});

  final int count;

  @override
  State<_RecentlyViewedProducts> createState() =>
      _RecentlyViewedProductsState();
}

class _RecentlyViewedProductsState extends State<_RecentlyViewedProducts> {
  late final OctopusStateObserver<OctopusState> observer;
  List<int> _visited = <int>[];
  List<ProductEntity> _products = <ProductEntity>[];
  @override
  void initState() {
    super.initState();
    observer = Octopus.of(context).stateObserver;
    observer.addListener(_onOctopusStateChanged);
    _onOctopusStateChanged();
  }

  @override
  void dispose() {
    observer.removeListener(_onOctopusStateChanged);
    super.dispose();
  }

  void _onOctopusStateChanged() {
    final history = observer.history.reversed.toList(growable: false);
    final count = widget.count;
    Timer(Duration.zero, () async {
      final visited = <int>{};
      final stopwatch = Stopwatch()..start();
      try {
        for (final e in history) {
          if (stopwatch.elapsed > const Duration(milliseconds: 8)) {
            await Future<void>.delayed(Duration.zero);
            stopwatch.reset();
          }
          if (visited.length >= count) break;
          e.state.visitChildNodes((node) {
            if (visited.length >= count) return false;
            if (node.name != Routes.product.name) return true;
            final id = switch (node.arguments['id']) {
              String id => int.tryParse(id),
              _ => null,
            };
            if (id == null) return true;
            visited.add(id);
            return true;
          });
        }
      } finally {
        stopwatch.stop();
      }
      if (!mounted) return;
      final newVisited = visited.take(count).toList(growable: false);
      if (listEquals(_visited, newVisited)) return;
      setState(() {
        _visited = newVisited;
        _products = newVisited
            .map<ProductEntity?>(
                (id) => ShopScope.getProductById(context, id, listen: false))
            .whereType<ProductEntity>()
            .toList(growable: false);
      });
    });
  }

  @override
  Widget build(BuildContext context) => _products.isEmpty
      ? SliverPadding(
          padding: ScaffoldPadding.of(context),
          sliver: SliverToBoxAdapter(
            child: Material(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 48,
                child: Center(
                  child: Text(
                    'No recently viewed products',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
              ),
            ),
          ),
        )
      : ProductsSliverGridView(
          products: _products,
        );
}
