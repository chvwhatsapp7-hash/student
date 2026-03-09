import 'package:flutter/material.dart';

class AppSheet {
  static void show(
      BuildContext context, {
        required Widget child,
        SheetSide side = SheetSide.bottom,
      }) {
    if (side == SheetSide.bottom) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => _SheetContainer(child: child),
      );
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Sheet",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: _alignment(side),
          child: _SheetContainer(
            width: side == SheetSide.left || side == SheetSide.right ? 320 : null,
            height: side == SheetSide.top || side == SheetSide.bottom ? 300 : null,
            child: child,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offset = _offset(side);

        return SlideTransition(
          position: Tween<Offset>(
            begin: offset,
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  static Alignment _alignment(SheetSide side) {
    switch (side) {
      case SheetSide.left:
        return Alignment.centerLeft;
      case SheetSide.right:
        return Alignment.centerRight;
      case SheetSide.top:
        return Alignment.topCenter;
      case SheetSide.bottom:
        return Alignment.bottomCenter;
    }
  }

  static Offset _offset(SheetSide side) {
    switch (side) {
      case SheetSide.left:
        return const Offset(-1, 0);
      case SheetSide.right:
        return const Offset(1, 0);
      case SheetSide.top:
        return const Offset(0, -1);
      case SheetSide.bottom:
        return const Offset(0, 1);
    }
  }
}

enum SheetSide {
  left,
  right,
  top,
  bottom,
}

class _SheetContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const _SheetContainer({
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        width: width ?? double.infinity,
        height: height,
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}
