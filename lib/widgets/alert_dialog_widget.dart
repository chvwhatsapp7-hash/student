import 'package:flutter/material.dart';

class CustomAlertDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String description,
    required String confirmText,
    String cancelText = "Cancel",
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            description,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }
}
