import 'package:example/src/feature/shop/model/product.dart';
import 'package:meta/meta.dart';

/// {@template favorite_state}
/// FavoriteState.
/// {@endtemplate}
sealed class FavoriteState extends _$FavoriteStateBase {
  /// {@macro favorite_state}
  const FavoriteState({
    required super.products,
    required super.message,
  });

  /// Idling state
  /// {@macro favorite_state}
  const factory FavoriteState.idle({
    required Set<ProductID> products,
    String message,
  }) = FavoriteState$Idle;

  /// Processing
  /// {@macro favorite_state}
  const factory FavoriteState.processing({
    required Set<ProductID> products,
    String message,
  }) = FavoriteState$Processing;

  /// Successful
  /// {@macro favorite_state}
  const factory FavoriteState.successful({
    required Set<ProductID> products,
    String message,
  }) = FavoriteState$Successful;

  /// An error has occurred
  /// {@macro favorite_state}
  const factory FavoriteState.error({
    required Set<ProductID> products,
    String message,
  }) = FavoriteState$Error;
}

/// Idling state
final class FavoriteState$Idle extends FavoriteState {
  const FavoriteState$Idle({
    required super.products,
    super.message = 'Idling',
  });
}

/// Processing
final class FavoriteState$Processing extends FavoriteState {
  const FavoriteState$Processing({
    required super.products,
    super.message = 'Processing',
  });
}

/// Successful
final class FavoriteState$Successful extends FavoriteState {
  const FavoriteState$Successful({
    required super.products,
    super.message = 'Successful',
  });
}

/// Error
final class FavoriteState$Error extends FavoriteState {
  const FavoriteState$Error({
    required super.products,
    super.message = 'An error has occurred.',
  });
}

/// Pattern matching for [FavoriteState].
typedef FavoriteStateMatch<R, S extends FavoriteState> = R Function(S state);

@immutable
abstract base class _$FavoriteStateBase {
  const _$FavoriteStateBase({
    required this.products,
    required this.message,
  });

  /// Products
  @nonVirtual
  final Set<ProductID> products;

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

  /// Pattern matching for [FavoriteState].
  R map<R>({
    required FavoriteStateMatch<R, FavoriteState$Idle> idle,
    required FavoriteStateMatch<R, FavoriteState$Processing> processing,
    required FavoriteStateMatch<R, FavoriteState$Successful> successful,
    required FavoriteStateMatch<R, FavoriteState$Error> error,
  }) =>
      switch (this) {
        FavoriteState$Idle s => idle(s),
        FavoriteState$Processing s => processing(s),
        FavoriteState$Successful s => successful(s),
        FavoriteState$Error s => error(s),
        _ => throw AssertionError(),
      };

  /// Pattern matching for [FavoriteState].
  R maybeMap<R>({
    required R Function() orElse,
    FavoriteStateMatch<R, FavoriteState$Idle>? idle,
    FavoriteStateMatch<R, FavoriteState$Processing>? processing,
    FavoriteStateMatch<R, FavoriteState$Successful>? successful,
    FavoriteStateMatch<R, FavoriteState$Error>? error,
  }) =>
      map<R>(
        idle: idle ?? (_) => orElse(),
        processing: processing ?? (_) => orElse(),
        successful: successful ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );

  /// Pattern matching for [FavoriteState].
  R? mapOrNull<R>({
    FavoriteStateMatch<R, FavoriteState$Idle>? idle,
    FavoriteStateMatch<R, FavoriteState$Processing>? processing,
    FavoriteStateMatch<R, FavoriteState$Successful>? successful,
    FavoriteStateMatch<R, FavoriteState$Error>? error,
  }) =>
      map<R?>(
        idle: idle ?? (_) => null,
        processing: processing ?? (_) => null,
        successful: successful ?? (_) => null,
        error: error ?? (_) => null,
      );

  @override
  int get hashCode => Object.hashAll([
        ...products,
        message,
      ]);

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  String toString() => 'FavoriteState{message: $message}';
}
