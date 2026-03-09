import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final Widget? header;
  final Widget? title;
  final Widget? description;
  final Widget? content;
  final Widget? footer;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double borderRadius;

  const CardWidget({
    super.key,
    this.header,
    this.title,
    this.description,
    this.content,
    this.footer,
    this.action,
    this.padding,
    this.backgroundColor,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: header,
              ),
            if (title != null) title!,
            if (description != null) description!,
            if (content != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: content,
              ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    footer!,
                    if (action != null) action!,
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}