import 'package:flutter/material.dart';

class Accordion extends StatelessWidget {
  final List<AccordionItem> items;

  const Accordion({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items,
    );
  }
}

class AccordionItem extends StatelessWidget {
  final String title;
  final Widget content;

  const AccordionItem({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconColor: Colors.grey,
      collapsedIconColor: Colors.grey,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: content,
        )
      ],
    );
  }
}
