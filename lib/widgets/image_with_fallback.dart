import 'package:flutter/material.dart';

class ImageWithFallback extends StatelessWidget {
  final String src;
  final String? alt;
  final BoxFit fit;
  final double? width;
  final double? height;
  final String errorAsset;

  const ImageWithFallback({
    super.key,
    required this.src,
    this.alt,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorAsset = "assets/error.png",
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      src,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          errorAsset,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }
}
