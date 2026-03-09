import 'package:flutter/material.dart';

enum BadgeVariant {
  defaultVariant,
  secondary,
  destructive,
  outline
}

class Badge extends StatelessWidget {
  final String text;
  final BadgeVariant variant;
  final Widget? child;

  const Badge({
    super.key,
    required this.text,
    this.variant = BadgeVariant.defaultVariant,
    this.child,
  });

  Color _getBackgroundColor(BuildContext context) {
    switch (variant) {
      case BadgeVariant.secondary:
        return Colors.blue.shade100;
      case BadgeVariant.destructive:
        return Colors.red.shade600;
      case BadgeVariant.outline:
        return Colors.transparent;
      case BadgeVariant.defaultVariant:
      default:
        return Colors.green.shade600;
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (variant) {
      case BadgeVariant.secondary:
        return Colors.blue.shade800;
      case BadgeVariant.destructive:
        return Colors.white;
      case BadgeVariant.outline:
        return Colors.black87;
      case BadgeVariant.defaultVariant:
      default:
        return Colors.white;
    }
  }

  BoxBorder? _getBorder() {
    if (variant == BadgeVariant.outline) {
      return Border.all(color: Colors.black26);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(6),
        border: _getBorder(),
      ),
      child: child ??
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getTextColor(context),
            ),
          ),
    );
  }
}