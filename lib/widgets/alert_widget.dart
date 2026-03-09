import 'package:flutter/material.dart';

enum AlertVariant { normal, destructive }

class CustomAlert extends StatelessWidget {
  final String title;
  final String description;
  final AlertVariant variant;
  final IconData? icon;

  const CustomAlert({
    super.key,
    required this.title,
    required this.description,
    this.variant = AlertVariant.normal,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    if (variant == AlertVariant.destructive) {
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red;
    } else {
      backgroundColor = Colors.grey.shade200;
      textColor = Colors.black87;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 2),
              child: Icon(icon, size: 18, color: textColor),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
