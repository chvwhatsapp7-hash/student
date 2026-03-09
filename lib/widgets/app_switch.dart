import 'package:flutter/material.dart';

class AppSwitch extends StatefulWidget {
  final bool value;
  final Function(bool)? onChanged;

  const AppSwitch({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch> {
  late bool isOn;

  @override
  void initState() {
    super.initState();
    isOn = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isOn,
      onChanged: (bool value) {
        setState(() {
          isOn = value;
        });

        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
      },
    );
  }
}
