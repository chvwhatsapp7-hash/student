import 'package:flutter/material.dart';

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;
  final bool isCurrentPage;

  BreadcrumbItem({
    required this.label,
    this.onTap,
    this.isCurrentPage = false,
  });
}

class Breadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final bool showEllipsis;
  final int maxItems;

  const Breadcrumb({
    super.key,
    required this.items,
    this.showEllipsis = false,
    this.maxItems = 4,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    int displayCount = items.length;
    bool useEllipsis = showEllipsis && items.length > maxItems;

    List<BreadcrumbItem> displayedItems = useEllipsis
        ? [
      items.first,
      ...items.sublist(items.length - (maxItems - 1))
    ]
        : items;

    for (int i = 0; i < displayedItems.length; i++) {
      final item = displayedItems[i];

      // Add item
      Widget crumb;
      if (item.isCurrentPage) {
        crumb = Text(
          item.label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        );
      } else {
        crumb = GestureDetector(
          onTap: item.onTap,
          child: Text(
            item.label,
            style: TextStyle(
              color: item.onTap != null ? Colors.blue.shade700 : Colors.black87,
              decoration: item.onTap != null ? TextDecoration.underline : null,
            ),
          ),
        );
      }

      children.add(crumb);

      // Add separator if not last
      if (i < displayedItems.length - 1) {
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ),
        );
      }
    }

    // Add ellipsis if needed
    if (useEllipsis) {
      children.insert(
        1,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: const [
              Icon(Icons.more_horiz, size: 16),
            ],
          ),
        ),
      );
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}
