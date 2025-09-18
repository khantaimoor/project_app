import 'package:flutter/material.dart';

class AnimationService {
  static Route<T> createRoute<T>({
    required Widget page,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      fullscreenDialog: fullscreenDialog,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.05);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween<Offset>(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var fadeAnimation = animation.drive(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    double beginY = 0.05,
    double endY = 0.0,
    Curve curve = Curves.easeInOutCubic,
  }) {
    var tween = Tween<double>(begin: beginY, end: endY).chain(
      CurveTween(curve: curve),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, tween.evaluate(animation) * 20),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
    double begin = 0.95,
    double end = 1.0,
    Curve curve = Curves.easeInOutCubic,
  }) {
    var tween = Tween(begin: begin, end: end).chain(
      CurveTween(curve: curve),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: tween.evaluate(animation),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
