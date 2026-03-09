import 'package:flutter/material.dart';

class AppProgress extends StatelessWidget {
  final double value; // 0 to 100
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;

  const AppProgress({
    super.key,
    required this.value,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (value.clamp(0, 100)) / 100,
        child: Container(
          decoration: BoxDecoration(
            color: progressColor ?? Colors.blue,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}
