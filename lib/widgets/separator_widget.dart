import 'package:flutter/material.dart';

class AppSeparator extends StatelessWidget {
  final Axis orientation;
  final double thickness;
  final Color? color;

  const AppSeparator({
    super.key,
    this.orientation = Axis.horizontal,
    this.thickness = 1,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (orientation == Axis.vertical) {
      return VerticalDivider(
        thickness: thickness,
        color: color ?? Colors.grey.shade300,
        width: thickness,
      );
    }

    return Divider(
      thickness: thickness,
      color: color ?? Colors.grey.shade300,
      height: thickness,
    );
  }
}
