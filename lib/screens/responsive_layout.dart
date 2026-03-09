import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget desktopLayout;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    required this.desktopLayout,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth < 768) {
          return mobileLayout;
        } else {
          return desktopLayout;
        }
      },
    );
  }
}
