import 'package:flutter/material.dart';

class AppToaster {
  static void show(
      BuildContext context, {
        required String message,
        Color backgroundColor = Colors.black,
        Duration duration = const Duration(seconds: 3),
      }) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
