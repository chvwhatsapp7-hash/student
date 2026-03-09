import 'package:flutter/material.dart';

class AppToggleGroup extends StatefulWidget {
  final List<String> items;
  final Function(int)? onSelected;

  const AppToggleGroup({
    super.key,
    required this.items,
    this.onSelected,
  });

  @override
  State<AppToggleGroup> createState() => _AppToggleGroupState();
}

class _AppToggleGroupState extends State<AppToggleGroup> {
  late List<bool> selected;

  @override
  void initState() {
    super.initState();
    selected = List.generate(widget.items.length, (index) => index == 0);
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(8),
      isSelected: selected,
      onPressed: (index) {
        setState(() {
          for (int i = 0; i < selected.length; i++) {
            selected[i] = i == index;
          }
        });

        if (widget.onSelected != null) {
          widget.onSelected!(index);
        }
      },
      children: widget.items
          .map((item) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(item),
      ))
          .toList(),
    );
  }
}
