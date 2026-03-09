import 'package:flutter/material.dart';

/// FORM WRAPPER
class AppForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Widget child;

  const AppForm({
    super.key,
    required this.formKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: child,
    );
  }
}

/// FORM ITEM (like FormItem)
class FormItem extends StatelessWidget {
  final Widget child;

  const FormItem({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }
}

/// FORM LABEL
class FormLabel extends StatelessWidget {
  final String text;

  const FormLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// FORM DESCRIPTION
class FormDescription extends StatelessWidget {
  final String text;

  const FormDescription({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    );
  }
}

/// FORM MESSAGE (error message)
class FormMessage extends StatelessWidget {
  final String message;

  const FormMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.red,
      ),
    );
  }
}
