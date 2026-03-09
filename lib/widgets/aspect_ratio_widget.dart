import 'package:flutter/material.dart';

class CustomAspectRatio extends StatelessWidget {
  final double ratio;
  final Widget child;

  const CustomAspectRatio({
    super.key,
    required this.ratio,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: ratio,
      child: child,
    );
  }
}