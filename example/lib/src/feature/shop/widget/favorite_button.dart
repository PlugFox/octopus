import 'package:example/src/feature/shop/model/product.dart';
import 'package:example/src/feature/shop/widget/shop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template favorite_button}
/// FavoriteButton widget.
/// {@endtemplate}
class FavoriteButton extends StatelessWidget {
  /// {@macro favorite_button}
  const FavoriteButton({
    required this.productId,
    super.key,
  });

  final ProductID productId;

  @override
  Widget build(BuildContext context) {
    final status = ShopScope.isFavorite(context, productId, listen: true);
    return RepaintBoundary(
      child: FloatingActionButton(
        onPressed: () {
          if (status) {
            ShopScope.removeFavorite(context, productId);
            HapticFeedback.lightImpact().ignore();
          } else {
            ShopScope.addFavorite(context, productId);
            HapticFeedback.mediumImpact().ignore();
          }
        },
        backgroundColor: status
            ? Theme.of(context).buttonTheme.colorScheme?.surface
            : Theme.of(context).primaryColor,
        shape: status
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: Theme.of(context).buttonTheme.colorScheme?.primary ??
                      Colors.transparent,
                ),
              )
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
        child: _FavoriteHeartBeatIcon(
          favorite: status,
        ),
      ),
    );
  }
}

class _FavoriteHeartBeatIcon extends StatefulWidget {
  const _FavoriteHeartBeatIcon({
    this.favorite = true,
    this.duration = const Duration(milliseconds: 650), // ignore: unused_element
    super.key, // ignore: unused_element
  });

  /// Is the icon currently filled in?
  final bool favorite;

  /// The duration of the animation.
  final Duration duration;

  @override
  State<_FavoriteHeartBeatIcon> createState() => _FavoriteHeartBeatIconState();
}

/// State for widget _FavoriteHeartBeatIcon.
class _FavoriteHeartBeatIconState extends State<_FavoriteHeartBeatIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heartbeat1, _heartbeat2;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.duration, value: 0);
    _heartbeat1 = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, .75, curve: Curves.easeInOut));
    _heartbeat2 = CurvedAnimation(
        parent: _controller,
        curve: const Interval(.5, 1, curve: Curves.easeInOut));
    if (!widget.favorite) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _FavoriteHeartBeatIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != _controller.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.favorite != oldWidget.favorite) {
      if (widget.favorite) {
        _controller.stop();
      } else {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (!widget.favorite)
            Positioned.fill(
              child: FadeTransition(
                opacity: ReverseAnimation(_heartbeat1),
                child: ScaleTransition(
                  scale:
                      Tween<double>(begin: 1, end: 1.75).animate(_heartbeat1),
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.redAccent.withAlpha(127),
                    size: 32,
                  ),
                ),
              ),
            ),
          if (!widget.favorite)
            Positioned.fill(
              child: FadeTransition(
                opacity: Tween<double>(begin: 0, end: .75)
                    .animate(ReverseAnimation(_heartbeat2)),
                child: ScaleTransition(
                  scale:
                      Tween<double>(begin: 0.8, end: 1.5).animate(_heartbeat2),
                  child: Icon(
                    Icons.favorite_border,
                    color: Colors.red.withAlpha(200),
                    size: 28,
                  ),
                ),
              ),
            ),
          Positioned.fill(
            key: const ValueKey<String>('_FavoriteHeartBeatIconState#icon'),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.bounceInOut,
                ),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.5, end: 1).animate(animation),
                  child: child,
                ),
              ),
              child: widget.favorite
                  ? const Icon(
                      Icons.favorite,
                      key: ValueKey('favorite'),
                      color: Colors.red,
                      size: 36,
                    )
                  : Icon(
                      Icons.favorite_border,
                      key: const ValueKey('favorite_border'),
                      color: Colors.grey.withAlpha(200),
                      size: 24,
                    ),
            ),
          ),
        ],
      );
}
