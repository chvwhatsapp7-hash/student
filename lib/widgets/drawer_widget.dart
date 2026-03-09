import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String title;
  final String description;
  final Widget? child;

  const AppDrawer({
    super.key,
    required this.title,
    required this.description,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Drawer Handle
          Center(
            child: Container(
              width: 60,
              height: 6,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          /// Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          /// Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 16),

          if (child != null) child!,
        ],
      ),
    );
  }
}

/// Helper function to open drawer
void openDrawer(
    BuildContext context, {
      required String title,
      required String description,
      Widget? child,
    }) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => AppDrawer(
      title: title,
      description: description,
      child: child,
    ),
  );
}
