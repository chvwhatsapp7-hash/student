import 'package:flutter/material.dart';

class AppRadioGroup<T> extends StatelessWidget {
  final T value;
  final List<AppRadioItem<T>> items;
  final ValueChanged<T?> onChanged;
  final double spacing;

  const AppRadioGroup({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: Row(
            children: [
              Radio<T>(
                value: item.value,
                groupValue: value,
                onChanged: onChanged,
              ),
              const SizedBox(width: 8),
              Expanded(child: item.child),
            ],
          ),
        ),
      )
          .toList(),
    );
  }
}

class AppRadioItem<T> {
  final T value;
  final Widget child;

  AppRadioItem({
    required this.value,
    required this.child,
  });
}
