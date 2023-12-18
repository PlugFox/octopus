import 'package:example/src/feature/shop/model/category.dart';
import 'package:example/src/feature/shop/model/product.dart';
import 'package:meta/meta.dart';

/// {@template shop_state}
/// ShopState.
/// {@endtemplate}
sealed class ShopState extends _$ShopStateBase {
  /// {@macro shop_state}
  const ShopState({
    required super.categories,
    required super.products,
    required super.message,
  });

  /// Idling state
  /// {@macro shop_state}
  const factory ShopState.idle({
    required List<CategoryEntity> categories,
    required List<ProductEntity> products,
    String message,
  }) = ShopState$Idle;

  /// Processing
  /// {@macro shop_state}
  const factory ShopState.processing({
    required List<CategoryEntity> categories,
    required List<ProductEntity> products,
    String message,
  }) = ShopState$Processing;

  /// Successful
  /// {@macro shop_state}
  const factory ShopState.successful({
    required List<CategoryEntity> categories,
    required List<ProductEntity> products,
    String message,
  }) = ShopState$Successful;

  /// An error has occurred
  /// {@macro shop_state}
  const factory ShopState.error({
    required List<CategoryEntity> categories,
    required List<ProductEntity> products,
    String message,
  }) = ShopState$Error;
}

/// Idling state
/// {@nodoc}
final class ShopState$Idle extends ShopState {
  /// {@nodoc}
  const ShopState$Idle({
    required super.categories,
    required super.products,
    super.message = 'Idling',
  });
}

/// Processing
/// {@nodoc}
final class ShopState$Processing extends ShopState {
  /// {@nodoc}
  const ShopState$Processing({
    required super.categories,
    required super.products,
    super.message = 'Processing',
  });
}

/// Successful
/// {@nodoc}
final class ShopState$Successful extends ShopState {
  /// {@nodoc}
  const ShopState$Successful({
    required super.categories,
    required super.products,
    super.message = 'Successful',
  });
}

/// Error
/// {@nodoc}
final class ShopState$Error extends ShopState {
  /// {@nodoc}
  const ShopState$Error({
    required super.categories,
    required super.products,
    super.message = 'An error has occurred.',
  });
}

/// Pattern matching for [ShopState].
typedef ShopStateMatch<R, S extends ShopState> = R Function(S state);

/// {@nodoc}
@immutable
abstract base class _$ShopStateBase {
  /// {@nodoc}
  const _$ShopStateBase({
    required this.categories,
    required this.products,
    required this.message,
  });

  /// Categories
  @nonVirtual
  final List<CategoryEntity> categories;

  /// Products
  @nonVirtual
  final List<ProductEntity> products;

  /// Message or state description.
  @nonVirtual
  final String message;

  /// If an error has occurred?
  bool get hasError => maybeMap<bool>(orElse: () => false, error: (_) => true);

  /// Is in progress state?
  bool get isProcessing =>
      maybeMap<bool>(orElse: () => false, processing: (_) => true);

  /// Is in idle state?
  bool get isIdling => !isProcessing;

  /// Pattern matching for [ShopState].
  R map<R>({
    required ShopStateMatch<R, ShopState$Idle> idle,
    required ShopStateMatch<R, ShopState$Processing> processing,
    required ShopStateMatch<R, ShopState$Successful> successful,
    required ShopStateMatch<R, ShopState$Error> error,
  }) =>
      switch (this) {
        ShopState$Idle s => idle(s),
        ShopState$Processing s => processing(s),
        ShopState$Successful s => successful(s),
        ShopState$Error s => error(s),
        _ => throw AssertionError(),
      };

  /// Pattern matching for [ShopState].
  R maybeMap<R>({
    required R Function() orElse,
    ShopStateMatch<R, ShopState$Idle>? idle,
    ShopStateMatch<R, ShopState$Processing>? processing,
    ShopStateMatch<R, ShopState$Successful>? successful,
    ShopStateMatch<R, ShopState$Error>? error,
  }) =>
      map<R>(
        idle: idle ?? (_) => orElse(),
        processing: processing ?? (_) => orElse(),
        successful: successful ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );

  /// Pattern matching for [ShopState].
  R? mapOrNull<R>({
    ShopStateMatch<R, ShopState$Idle>? idle,
    ShopStateMatch<R, ShopState$Processing>? processing,
    ShopStateMatch<R, ShopState$Successful>? successful,
    ShopStateMatch<R, ShopState$Error>? error,
  }) =>
      map<R?>(
        idle: idle ?? (_) => null,
        processing: processing ?? (_) => null,
        successful: successful ?? (_) => null,
        error: error ?? (_) => null,
      );

  @override
  int get hashCode => Object.hashAll([
        ...categories,
        ...products,
        message,
      ]);

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  String toString() => 'ShopState{message: $message}';
}
