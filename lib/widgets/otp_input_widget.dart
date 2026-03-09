import 'package:flutter/material.dart';

class OTPInput extends StatefulWidget {
  final int length;
  final Function(String) onCompleted;

  const OTPInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
  });

  @override
  State<OTPInput> createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();

    controllers =
        List.generate(widget.length, (_) => TextEditingController());
    focusNodes =
        List.generate(widget.length, (_) => FocusNode());
  }

  void checkCompletion() {
    String otp = controllers.map((c) => c.text).join();

    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Container(
          width: 45,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            decoration: InputDecoration(
              counterText: "",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < widget.length - 1) {
                focusNodes[index + 1].requestFocus();
              }

              if (value.isEmpty && index > 0) {
                focusNodes[index - 1].requestFocus();
              }

              checkCompletion();
            },
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}
