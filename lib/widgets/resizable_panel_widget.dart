import 'package:flutter/material.dart';

class ResizablePanelGroup extends StatefulWidget {
  final Widget first;
  final Widget second;
  final bool vertical;

  const ResizablePanelGroup({
    super.key,
    required this.first,
    required this.second,
    this.vertical = false,
  });

  @override
  State<ResizablePanelGroup> createState() => _ResizablePanelGroupState();
}

class _ResizablePanelGroupState extends State<ResizablePanelGroup> {
  double ratio = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (widget.vertical) {
          final height = constraints.maxHeight;

          return Column(
            children: [
              SizedBox(height: height * ratio, child: widget.first),

              GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    ratio += details.delta.dy / height;
                    ratio = ratio.clamp(0.1, 0.9);
                  });
                },
                child: Container(
                  height: 6,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.drag_handle, size: 16),
                  ),
                ),
              ),

              Expanded(child: widget.second),
            ],
          );
        }

        final width = constraints.maxWidth;

        return Row(
          children: [
            SizedBox(width: width * ratio, child: widget.first),

            GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  ratio += details.delta.dx / width;
                  ratio = ratio.clamp(0.1, 0.9);
                });
              },
              child: Container(
                width: 6,
                color: Colors.grey.shade300,
                child: const Center(
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Icon(Icons.drag_handle, size: 16),
                  ),
                ),
              ),
            ),

            Expanded(child: widget.second),
          ],
        );
      },
    );
  }
}
