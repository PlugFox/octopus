import 'package:example/src/common/controller/sequential_controller_concurrency.dart';
import 'package:example/src/common/controller/state_controller.dart';
import 'package:example/src/feature/shop/controller/shop_state.dart';
import 'package:example/src/feature/shop/data/product_repository.dart';

final class ShopController extends StateController<ShopState>
    with SequentialControllerConcurrency {
  ShopController(
      {required IProductRepository repository,
      super.initialState = const ShopState.idle(
        products: [],
        categories: [],
        message: 'Initial',
      )})
      : _productRepository = repository;

  final IProductRepository _productRepository;

  /// Fetches the data.
  void fetch() => handle(
        () async {
          setState(
            ShopState.processing(
              products: state.products,
              categories: state.categories,
              message: 'Fetching',
            ),
          );

          final categories =
              await _productRepository.fetchCategories().toList();
          final products = await _productRepository.fetchProducts().toList();
          // Remove empty categories
          categories
            ..removeWhere((e) =>
                !e.isRoot &&
                products.every((p) => p.category != e.id) &&
                categories.every((p) => p.parent != e.id))
            // Remove empty root categories
            ..removeWhere(
              (e) =>
                  e.isRoot &&
                  products.every((p) => p.category != e.id) &&
                  categories.every((p) => p.parent != e.id),
            )
            // Sort categories
            ..sort();
          products.sort(); // Sort products
          setState(
            ShopState.successful(
              products: products,
              categories: categories,
              message: 'Successful',
            ),
          );
        },
        (error, _) => setState(
          ShopState.idle(
            products: state.products,
            categories: state.categories,
            message: 'Error: $error', // ErrorUtil.formatMessage(error)
          ),
        ),
        () => setState(
          ShopState.idle(
            products: state.products,
            categories: state.categories,
            message: 'Idle',
          ),
        ),
      );
}
