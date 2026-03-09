import 'package:flutter/material.dart';

class Collapsible extends StatefulWidget {
  final Widget trigger;
  final Widget content;

  const Collapsible({
    super.key,
    required this.trigger,
    required this.content,
  });

  @override
  State<Collapsible> createState() => _CollapsibleState();
}

class _CollapsibleState extends State<Collapsible> {
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
          child: widget.trigger,
        ),

        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox(),
          secondChild: widget.content,
          crossFadeState:
          isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        ),
      ],
    );
  }
}