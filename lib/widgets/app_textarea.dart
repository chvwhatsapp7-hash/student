import 'package:flutter/material.dart';

class AppTextarea extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final bool enabled;

  const AppTextarea({
    super.key,
    this.controller,
    this.hintText,
    this.minLines = 3,
    this.maxLines = 6,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}
