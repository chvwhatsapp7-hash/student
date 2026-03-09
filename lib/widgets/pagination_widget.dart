import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  List<Widget> _buildPageButtons() {
    List<Widget> buttons = [];

    for (int i = 1; i <= totalPages; i++) {
      buttons.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor:
              i == currentPage ? Colors.grey.shade300 : null,
            ),
            onPressed: () => onPageChanged(i),
            child: Text(i.toString()),
          ),
        ),
      );
    }

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1
              ? () => onPageChanged(currentPage - 1)
              : null,
        ),

        ..._buildPageButtons(),

        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
        ),

      ],
    );
  }
}
