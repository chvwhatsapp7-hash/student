import 'package:flutter/material.dart';

class AppSelect<T> extends StatelessWidget {
  final T? value;
  final List<AppSelectItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? placeholder;

  const AppSelect({
    super.key,
    this.value,
    required this.items,
    required this.onChanged,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: placeholder != null ? Text(placeholder!) : null,
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
          value: item.value,
          child: item.child,
        ),
      )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class AppSelectItem<T> {
  final T value;
  final Widget child;

  AppSelectItem({
    required this.value,
    required this.child,
  });
}
