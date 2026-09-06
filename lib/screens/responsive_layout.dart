import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget? tabletLayout;
  final Widget desktopLayout;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    this.tabletLayout,
    required this.desktopLayout,
  });

  static bool isMobile(BuildContext context) => Responsive.isMobile(context);
  static bool isTablet(BuildContext context) => Responsive.isTablet(context);
  static bool isDesktop(BuildContext context) => Responsive.isDesktop(context);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth >= Responsive.kTabletBreakpoint) {
          return desktopLayout;
        } else if (constraints.maxWidth >= Responsive.kMobileBreakpoint) {
          return tabletLayout ?? desktopLayout;
        } else {
          return mobileLayout;
        }
      },
    );
  }
}
