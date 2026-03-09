import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String description;
  final Widget? content;
  final List<Widget>? actions;

  const AppDialog({
    super.key,
    required this.title,
    required this.description,
    this.content,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            /// Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            if (content != null) ...[
              const SizedBox(height: 16),
              content!,
            ],

            const SizedBox(height: 20),

            /// Footer / Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions ?? [],
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to open dialog
void showAppDialog(
    BuildContext context, {
      required String title,
      required String description,
      Widget? content,
      List<Widget>? actions,
    }) {
  showDialog(
    context: context,
    builder: (context) => AppDialog(
      title: title,
      description: description,
      content: content,
      actions: actions,
    ),
  );
}