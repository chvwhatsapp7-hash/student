import 'package:flutter/material.dart';

class DropdownMenuItemData {
  final String title;
  final IconData? icon;
  final VoidCallback onTap;

  DropdownMenuItemData({
    required this.title,
    this.icon,
    required this.onTap,
  });
}

class AppDropdownMenu extends StatelessWidget {
  final Widget trigger;
  final List<DropdownMenuItemData> items;

  const AppDropdownMenu({
    super.key,
    required this.trigger,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DropdownMenuItemData>(
      tooltip: "",
      offset: const Offset(0, 40),
      itemBuilder: (context) {
        return items.map((item) {
          return PopupMenuItem<DropdownMenuItemData>(
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
      onSelected: (item) {
        item.onTap();
      },
      child: trigger,
    );
  }
}
