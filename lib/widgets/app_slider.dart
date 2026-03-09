import 'package:flutter/material.dart';

class AppSlider extends StatefulWidget {
  final double min;
  final double max;
  final double start;
  final double end;
  final Function(RangeValues)? onChanged;

  const AppSlider({
    super.key,
    this.min = 0,
    this.max = 100,
    this.start = 20,
    this.end = 80,
    this.onChanged,
  });

  @override
  State<AppSlider> createState() => _AppSliderState();
}

class _AppSliderState extends State<AppSlider> {
  late RangeValues values;

  @override
  void initState() {
    super.initState();
    values = RangeValues(widget.start, widget.end);
  }

  @override
  Widget build(BuildContext context) {
    return RangeSlider(
      min: widget.min,
      max: widget.max,
      values: values,
      labels: RangeLabels(
        values.start.round().toString(),
        values.end.round().toString(),
      ),
      onChanged: (RangeValues newValues) {
        setState(() {
          values = newValues;
        });

        if (widget.onChanged != null) {
          widget.onChanged!(newValues);
        }
      },
    );
  }
}
