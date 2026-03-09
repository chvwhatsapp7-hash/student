import 'package:flutter/material.dart';

class AppTooltip extends StatelessWidget {
  final String message;
  final Widget child;

  const AppTooltip({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      waitDuration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      child: child,
    );
  }
}
