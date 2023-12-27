import 'package:example/src/common/router/routes.dart';
import 'package:example/src/feature/shop/widget/shop_scope.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';

/// {@template catalog_breadcrumbs}
/// CatalogBreadcrumbs widget.
/// {@endtemplate}
class CatalogBreadcrumbs extends StatefulWidget {
  const CatalogBreadcrumbs._({
    this.productId,
    this.categoryId,
    this.rebuilds = false,
    super.key,
  });

  /// {@macro catalog_breadcrumbs}
  factory CatalogBreadcrumbs.category({
    required String id,
    bool rebuilds = false,
    Key? key,
  }) =>
      CatalogBreadcrumbs._(
        categoryId: id,
        rebuilds: rebuilds,
        key: key,
      );

  /// {@macro catalog_breadcrumbs}
  factory CatalogBreadcrumbs.product({
    required int id,
    bool rebuilds = false,
    Key? key,
  }) =>
      CatalogBreadcrumbs._(
        productId: id,
        rebuilds: rebuilds,
        key: key,
      );

  /// Current category id
  final String? categoryId;

  /// Current product id
  final int? productId;

  /// Rebuid breadcrumbs on state change
  final bool rebuilds;

  /// Height of the breadcrumbs
  static const double height = 32;

  @override
  State<CatalogBreadcrumbs> createState() => _CatalogBreadcrumbsState();
}

class _CatalogBreadcrumbsState extends State<CatalogBreadcrumbs> {
  static const double minWidth = 64;
  static const double maxWidth = 128;

  late final Octopus _router;
  late final OctopusStateObserver _stateObserver;
  List<String> _categories = <String>[];
  List<String> _products = <String>[];
  List<(Widget, VoidCallback?)> _actions = <(Widget, VoidCallback?)>[];

  @override
  void initState() {
    super.initState();
    _router = context.octopus;
    _stateObserver = _router.observer;
    if (widget.rebuilds) _stateObserver.addListener(_onStateChange);
    _onStateChange(rebuild: true);
  }

  @override
  void didUpdateWidget(covariant CatalogBreadcrumbs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rebuilds != oldWidget.rebuilds) {
      if (widget.rebuilds) {
        _stateObserver.addListener(_onStateChange);
      } else {
        _stateObserver.removeListener(_onStateChange);
      }
    }
  }

  @override
  void dispose() {
    if (widget.rebuilds) _stateObserver.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange({bool rebuild = false}) {
    if (!mounted) return;
    final categories = <String>[];
    final products = <String>[];
    final currentCategoryId = widget.categoryId;
    final currentProductId = widget.productId?.toString();
    _stateObserver.value.visitChildNodes((node) {
      final id = node.arguments['id'];
      if (id == null) return true;
      if (node.name == Routes.category.name) {
        if (id == currentCategoryId) return false;
        categories.add(id);
      } else if (node.name == Routes.product.name) {
        if (id == currentProductId) return false;
        products.add(id);
      }
      return true;
    });
    if (!rebuild &&
        listEquals(_categories, categories) &&
        listEquals(_products, products)) return;
    setState(() {
      _categories = categories;
      _products = products;
      _actions = _buildActions(categories, products);
    });
  }

  List<(Widget, VoidCallback?)> _buildActions(
      List<String> categories, List<String> products) {
    final currentCategoryId = widget.categoryId;
    final currentProductId = widget.productId;
    const defaultTextStyle = TextStyle(
      fontSize: 14,
      height: 0,
      letterSpacing: -0.5,
      fontWeight: FontWeight.w600,
    );

    void goToCatalog() => _router.setState(
          (state) => state
            ..arguments['shop'] = 'catalog'
            ..removeByName(Routes.category.name)
            ..removeByName(Routes.product.name),
        );

    void popToCategory(String id) {
      final doNotPop = <String>{...categories.takeWhile((e) => e != id), id};
      _router.setState(
        (state) => state
          ..arguments['shop'] = 'catalog'
          ..removeWhere((node) =>
              node.name == Routes.product.name ||
              (node.name == Routes.category.name &&
                  !doNotPop.contains(node.arguments['id']))),
      );
    }

    void popToProduct(String id) {
      final doNotPop = <String>{...products.takeWhile((e) => e != id), id};
      if (doNotPop.isEmpty) return; // Do nothing
      _router.setState(
        (state) => state
          ..arguments['shop'] = 'catalog'
          ..removeWhere((node) =>
              node.name == Routes.category.name &&
              !doNotPop.contains(node.arguments['id'])),
      );
    }

    String getCategoryTitleById(String id) =>
        ShopScope.getCategoryById(context, id, listen: false)?.category.title ??
        id;

    String getProductTitleById(Object? id) =>
        ShopScope.getProductById(
                context,
                switch (id) {
                  String id => int.tryParse(id) ?? -1,
                  int id => id,
                  _ => -1,
                },
                listen: false)
            ?.title ??
        id.toString();

    return <(Widget, VoidCallback?)>[
      // Catalog - always present as a root node
      (
        const Text(
          'Catalog',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: defaultTextStyle,
        ),
        goToCatalog,
      ),
      // Categories
      for (final id in categories)
        (
          Text(
            getCategoryTitleById(id),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: defaultTextStyle,
          ),
          () => popToCategory(id),
        ),
      // Products
      for (final id in products)
        (
          Text(
            getProductTitleById(id),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: defaultTextStyle,
          ),
          () => popToProduct(id),
        ),
      if (currentProductId != null)
        // Current product
        (
          Text(
            getProductTitleById(currentProductId),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: defaultTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          null,
        )
      else if (currentCategoryId != null)
        // Current category
        (
          Text(
            getCategoryTitleById(currentCategoryId),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: defaultTextStyle.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          null,
        ),
    ];
  }

  Widget buildAction(Widget title, [VoidCallback? callback]) => Flexible(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: minWidth,
            maxWidth: maxWidth,
          ),
          child: TextButton(
            onPressed: callback,
            child: title,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => _actions.isEmpty
      ? const SizedBox.shrink()
      : Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: CatalogBreadcrumbs.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                const chevronWidth = 24.0;
                const chevron = SizedBox.square(
                  dimension: chevronWidth,
                  child: Icon(
                    Icons.chevron_right,
                    size: chevronWidth,
                  ),
                );
                final maxActionsWidth = _actions.length * maxWidth +
                    chevronWidth * (_actions.length - 1);
                final actions = <Widget>[];
                if (_actions.length < 3 ||
                    constraints.maxWidth >= maxActionsWidth) {
                  var action = _actions.first;
                  actions.add(buildAction(action.$1, action.$2));
                  for (var i = 1; i < _actions.length; i++) {
                    action = _actions[i];
                    actions
                      ..add(chevron)
                      ..add(buildAction(action.$1, action.$2));
                  }
                } else {
                  final [first, ...menu, last] = _actions;
                  actions
                    ..add(buildAction(first.$1, first.$2))
                    ..add(chevron)
                    ..add(_CatalogBreadcrumbs$DropdownMenu(menu))
                    ..add(chevron)
                    ..add(buildAction(last.$1, last.$2));
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: actions,
                  ),
                );
              }),
            ),
          ),
        );
}

class _CatalogBreadcrumbs$DropdownMenu extends StatefulWidget {
  const _CatalogBreadcrumbs$DropdownMenu(this.actions);

  final List<(Widget, void Function()?)> actions;

  @override
  State<_CatalogBreadcrumbs$DropdownMenu> createState() =>
      _CatalogBreadcrumbs$DropdownMenuState();
}

class _CatalogBreadcrumbs$DropdownMenuState
    extends State<_CatalogBreadcrumbs$DropdownMenu> {
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isHovered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => _isHovered.value = true,
        onExit: (_) => _isHovered.value = false,
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: PopupMenuButton<VoidCallback>(
            iconSize: 24,
            offset: const Offset(0, 48),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            itemBuilder: (_) => _builder(),
            tooltip: 'Select folder',
            onSelected: (fn) => Future<void>.delayed(
              const Duration(milliseconds: 500),
              fn,
            ).ignore(),
            icon: Stack(
              alignment: Alignment.center,
              fit: StackFit.passthrough,
              children: <Widget>[
                // Three dots
                const Icon(Icons.more_horiz),

                // Hovered underline
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: 24,
                    height: 1,
                    child: ValueListenableBuilder(
                      valueListenable: _isHovered,
                      builder: (context, isHovered, _) => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: isHovered
                            ? Divider(
                                height: 2,
                                color: Colors.grey.shade600,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            splashRadius: 18,
          ),
        ),
      );

  List<PopupMenuEntry<VoidCallback>> _builder() {
    if (widget.actions.isEmpty) {
      assert(false, 'No entities to show in dropdown breadcrumbs');
      return const <PopupMenuEntry<VoidCallback>>[];
    }
    return <PopupMenuEntry<VoidCallback>>[
      for (final action in widget.actions)
        PopupMenuItem<VoidCallback>(
          value: action.$2,
          child: action.$1,
        ),
    ];
  }
}
