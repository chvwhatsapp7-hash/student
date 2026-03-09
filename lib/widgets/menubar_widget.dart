import 'package:flutter/material.dart';

class MenuItemData {
  final String title;
  final IconData? icon;
  final VoidCallback onTap;

  MenuItemData({
    required this.title,
    this.icon,
    required this.onTap,
  });
}

class MenuBarItem extends StatelessWidget {
  final String title;
  final List<MenuItemData> items;

  const MenuBarItem({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuItemData>(
      tooltip: "",
      onSelected: (item) => item.onTap(),
      itemBuilder: (context) {
        return items.map((item) {
          return PopupMenuItem<MenuItemData>(
            value: item,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(item.title),
              ],
            ),
          );
        }).toList();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class AppMenuBar extends StatelessWidget {
  final List<MenuBarItem> menus;

  const AppMenuBar({
    super.key,
    required this.menus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: menus,
      ),
    );
  }
}
