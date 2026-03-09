import 'package:flutter/material.dart';

class AppToggle extends StatefulWidget {
  final Widget child;
  final bool initialValue;
  final Function(bool)? onChanged;

  const AppToggle({
    super.key,
    required this.child,
    this.initialValue = false,
    this.onChanged,
  });

  @override
  State<AppToggle> createState() => _AppToggleState();
}

class _AppToggleState extends State<AppToggle> {
  late bool isActive;

  @override
  void initState() {
    super.initState();
    isActive = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isActive = !isActive;
        });

        widget.onChanged?.call(isActive);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.transparent,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
          child: widget.child, // ✅ Correct usage
        ),
      ),
    );
  }
}
