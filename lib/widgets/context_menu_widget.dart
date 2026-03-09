import 'package:flutter/material.dart';

class ContextMenuItemData {
  final String title;
  final IconData? icon;
  final VoidCallback onTap;

  ContextMenuItemData({
    required this.title,
    this.icon,
    required this.onTap,
  });
}

class ContextMenuTrigger extends StatelessWidget {
  final Widget child;
  final List<ContextMenuItemData> items;

  const ContextMenuTrigger({
    super.key,
    required this.child,
    required this.items,
  });

  void _showContextMenu(BuildContext context, Offset position) async {
    final selected = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: items.map((item) {
        return PopupMenuItem(
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
      }).toList(),
    );

    if (selected != null) {
      selected.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) {
        _showContextMenu(context, details.globalPosition);
      },
      child: child,
    );
  }
}
