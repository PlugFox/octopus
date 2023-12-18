import 'package:example/src/common/controller/sequential_controller_concurrency.dart';
import 'package:example/src/common/controller/state_controller.dart';
import 'package:example/src/feature/shop/controller/favorite_state.dart';
import 'package:example/src/feature/shop/data/product_repository.dart';
import 'package:example/src/feature/shop/model/product.dart';

final class FavoriteController extends StateController<FavoriteState>
    with SequentialControllerConcurrency {
  FavoriteController(
      {required IProductRepository repository,
      super.initialState = const FavoriteState.idle(
        products: <ProductID>{},
        message: 'Initial',
      )})
      : _productRepository = repository;

  final IProductRepository _productRepository;

  /// Fetches the data.
  void fetch() => handle(
        () async {
          setState(
            FavoriteState.processing(
              products: state.products,
              message: 'Fetching',
            ),
          );
          final products = await _productRepository.fetchFavoriteProducts();
          setState(
            FavoriteState.successful(
              products: products,
              message: 'Successful',
            ),
          );
        },
        (error, _) => setState(
          FavoriteState.idle(
            products: state.products,
            message: 'Error: $error', // ErrorUtil.formatMessage(error)
          ),
        ),
        () => setState(
          FavoriteState.idle(
            products: state.products,
            message: 'Idle',
          ),
        ),
      );

  /// Adds a product to the favorite list.
  void add(ProductID id) => handle(
        () async {
          setState(
            FavoriteState.processing(
              products: state.products,
              message: 'Adding',
            ),
          );
          await _productRepository.addFavoriteProduct(id);
          final products = await _productRepository.fetchFavoriteProducts();
          setState(
            FavoriteState.successful(
              products: products,
              message: 'Successful',
            ),
          );
        },
        (error, _) => setState(
          FavoriteState.idle(
            products: state.products,
            message: 'Error: $error', // ErrorUtil.formatMessage(error)
          ),
        ),
        () => setState(
          FavoriteState.idle(
            products: state.products,
            message: 'Idle',
          ),
        ),
      );

  /// Removes a product from the favorite list.
  void remove(ProductID id) => handle(
        () async {
          setState(
            FavoriteState.processing(
              products: state.products,
              message: 'Removing',
            ),
          );
          await _productRepository.removeFavoriteProduct(id);
          final products = await _productRepository.fetchFavoriteProducts();
          setState(
            FavoriteState.successful(
              products: products,
              message: 'Successful',
            ),
          );
        },
        (error, _) => setState(
          FavoriteState.idle(
            products: state.products,
            message: 'Error: $error', // ErrorUtil.formatMessage(error)
          ),
        ),
        () => setState(
          FavoriteState.idle(
            products: state.products,
            message: 'Idle',
          ),
        ),
      );
}
