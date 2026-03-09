import 'package:flutter/material.dart';

class AppLabel extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const AppLabel({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? Colors.black87,
      ),
    );
  }
}
