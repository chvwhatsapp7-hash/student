import 'package:flutter/material.dart';

enum ScreenType { smallMobile, mobile, tablet, desktop }

class Responsive {
  static const double kSmallMobileBreakpoint = 380.0;
  static const double kMobileBreakpoint = 600.0;
  static const double kTabletBreakpoint = 1024.0;
  static const double kMaxContentWidth = 1200.0;

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;

  static bool isSmallMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < kSmallMobileBreakpoint;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < kMobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= kMobileBreakpoint && w < kTabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= kTabletBreakpoint;

  static ScreenType screenType(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < kSmallMobileBreakpoint) return ScreenType.smallMobile;
    if (w < kMobileBreakpoint) return ScreenType.mobile;
    if (w < kTabletBreakpoint) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? smallMobile,
    T? tablet,
    T? desktop,
  }) {
    final st = screenType(context);
    switch (st) {
      case ScreenType.smallMobile:
        return smallMobile ?? mobile;
      case ScreenType.mobile:
        return mobile;
      case ScreenType.tablet:
        return tablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }

  static EdgeInsets horizontalPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < kSmallMobileBreakpoint) return const EdgeInsets.symmetric(horizontal: 12);
    if (w < kMobileBreakpoint) return const EdgeInsets.symmetric(horizontal: 16);
    if (w < kTabletBreakpoint) return const EdgeInsets.symmetric(horizontal: 24);
    return const EdgeInsets.symmetric(horizontal: 32);
  }

  static int gridColumns(BuildContext context, {int mobile = 1, int tablet = 2, int desktop = 3}) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet;
    return mobile;
  }
}

// Global top-level backward compatibility helpers
bool isTablet(BuildContext context) => Responsive.isTablet(context);
bool isDesktop(BuildContext context) => Responsive.isDesktop(context);
bool isMobile(BuildContext context) => Responsive.isMobile(context);

/// Constrains content width on larger screens and centers it nicely
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = Responsive.kMaxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// A clean LayoutBuilder wrapper for responsive UI
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints, ScreenType screenType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        ScreenType type;
        if (constraints.maxWidth < Responsive.kSmallMobileBreakpoint) {
          type = ScreenType.smallMobile;
        } else if (constraints.maxWidth < Responsive.kMobileBreakpoint) {
          type = ScreenType.mobile;
        } else if (constraints.maxWidth < Responsive.kTabletBreakpoint) {
          type = ScreenType.tablet;
        } else {
          type = ScreenType.desktop;
        }
        return builder(context, constraints, type);
      },
    );
  }
}
