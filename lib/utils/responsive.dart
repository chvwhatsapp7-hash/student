import 'package:flutter/material.dart';

// Check if the current screen width is considered mobile
class Responsive {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }
}

// Optional helper for tablet
bool isTablet(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width >= 768 && width < 1024;
}

// Optional helper for desktop
bool isDesktop(BuildContext context) {
  return MediaQuery.of(context).size.width >= 1024;
}
