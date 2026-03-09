import 'package:flutter/material.dart';

class AppInput extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool enabled;
  final String? Function(String?)? validator;

  const AppInput({
    super.key,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
