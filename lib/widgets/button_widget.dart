import 'package:flutter/material.dart';

enum ButtonVariant {
  defaultVariant,
  destructive,
  outline,
  secondary,
  ghost,
  link
}

enum ButtonSize {
  defaultSize,
  sm,
  lg,
  icon
}

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? icon;
  final bool isDisabled;

  const ButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.defaultVariant,
    this.size = ButtonSize.defaultSize,
    this.icon,
    this.isDisabled = false,
  });

  Color _getBackgroundColor(BuildContext context) {
    switch (variant) {
      case ButtonVariant.destructive:
        return Colors.red.shade600;
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.secondary:
        return Colors.blue.shade100;
      case ButtonVariant.ghost:
        return Colors.transparent;
      case ButtonVariant.link:
        return Colors.transparent;
      case ButtonVariant.defaultVariant:
      default:
        return Colors.green.shade600;
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (variant) {
      case ButtonVariant.destructive:
        return Colors.white;
      case ButtonVariant.outline:
        return Colors.black87;
      case ButtonVariant.secondary:
        return Colors.blue.shade800;
      case ButtonVariant.ghost:
        return Colors.black87;
      case ButtonVariant.link:
        return Colors.blue.shade700;
      case ButtonVariant.defaultVariant:
      default:
        return Colors.white;
    }
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.sm:
        return 36;
      case ButtonSize.lg:
        return 48;
      case ButtonSize.icon:
        return 36;
      case ButtonSize.defaultSize:
      default:
        return 40;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 12);
      case ButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 24);
      case ButtonSize.icon:
        return const EdgeInsets.all(8);
      case ButtonSize.defaultSize:
      default:
        return const EdgeInsets.symmetric(horizontal: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _getHeight(),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey.shade400 : _getBackgroundColor(context),
          foregroundColor: _getTextColor(context),
          padding: _getPadding(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: variant == ButtonVariant.outline ? BorderSide(color: Colors.black26) : BorderSide.none,
          ),
          elevation: 0,
        ),
        onPressed: isDisabled ? null : onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
