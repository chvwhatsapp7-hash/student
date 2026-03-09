import 'package:flutter/material.dart';

class AppScrollArea extends StatelessWidget {
  final Widget child;
  final Axis direction;
  final bool showScrollbar;

  const AppScrollArea({
    super.key,
    required this.child,
    this.direction = Axis.vertical,
    this.showScrollbar = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();

    Widget scrollView = SingleChildScrollView(
      controller: controller,
      scrollDirection: direction,
      child: child,
    );

    if (showScrollbar) {
      return Scrollbar(
        controller: controller,
        thumbVisibility: true,
        child: scrollView,
      );
    }

    return scrollView;
  }
}
