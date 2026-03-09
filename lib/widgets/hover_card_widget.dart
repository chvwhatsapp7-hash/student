import 'package:flutter/material.dart';

class HoverCard extends StatefulWidget {
  final Widget trigger;
  final Widget content;

  const HoverCard({
    super.key,
    required this.trigger,
    required this.content,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  OverlayEntry? overlayEntry;

  void showOverlay(BuildContext context) {
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 100,
        left: 100,
        child: Material(
          elevation: 6,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.content,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  void hideOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => showOverlay(context),
      onExit: (_) => hideOverlay(),
      child: widget.trigger,
    );
  }
}
