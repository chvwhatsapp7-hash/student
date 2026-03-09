import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final double size;
  final String? imageUrl;
  final String? fallbackText;

  const CustomAvatar({
    super.key,
    this.size = 40, // default size
    this.imageUrl,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Text(
        fallbackText != null ? fallbackText! : "",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      )
          : null,
    );
  }
}
