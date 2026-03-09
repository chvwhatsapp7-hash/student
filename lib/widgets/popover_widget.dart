import 'package:flutter/material.dart';

class AppPopover extends StatefulWidget {
  final Widget trigger;
  final Widget content;

  const AppPopover({
    super.key,
    required this.trigger,
    required this.content,
  });

  @override
  State<AppPopover> createState() => _AppPopoverState();
}

class _AppPopoverState extends State<AppPopover> {
  OverlayEntry? _overlayEntry;

  void _togglePopover() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlay();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + renderBox.size.height + 8,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: widget.content,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePopover,
      child: widget.trigger,
    );
  }
}
