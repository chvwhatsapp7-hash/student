import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool disabled;
  final double size;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.disabled = false,
    this.size = 24.0, // default to 24px similar to size-4
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.inputDecorationTheme.fillColor ?? Colors.grey.shade200;

    return SizedBox(
      width: size,
      height: size,
      child: Checkbox(
        value: value,
        onChanged: disabled ? null : onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        activeColor: primaryColor,
        fillColor: MaterialStateProperty.resolveWith<Color?>(
              (states) {
            if (states.contains(MaterialState.disabled)) {
              return backgroundColor.withOpacity(0.5);
            }
            if (states.contains(MaterialState.selected)) {
              return primaryColor;
            }
            return backgroundColor;
          },
        ),
        checkColor: Colors.white, // equivalent to CheckIcon
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
