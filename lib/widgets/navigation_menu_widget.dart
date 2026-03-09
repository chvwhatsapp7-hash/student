import 'package:flutter/material.dart';

class NavigationMenuItemData {
  final String title;
  final List<NavigationSubItem>? children;
  final VoidCallback? onTap;

  NavigationMenuItemData({
    required this.title,
    this.children,
    this.onTap,
  });
}

class NavigationSubItem {
  final String title;
  final VoidCallback onTap;

  NavigationSubItem({
    required this.title,
    required this.onTap,
  });
}

class AppNavigationMenu extends StatelessWidget {
  final List<NavigationMenuItemData> items;

  const AppNavigationMenu({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items.map((item) {
          if (item.children != null && item.children!.isNotEmpty) {
            return PopupMenuButton<NavigationSubItem>(
              tooltip: "",
              onSelected: (subItem) => subItem.onTap(),
              itemBuilder: (context) {
                return item.children!
                    .map((sub) => PopupMenuItem(
                  value: sub,
                  child: Text(sub.title),
                ))
                    .toList();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            );
          } else {
            return InkWell(
              onTap: item.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }
        }).toList(),
      ),
    );
  }
}
