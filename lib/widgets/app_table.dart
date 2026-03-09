import 'package:flutter/material.dart';

class AppTable extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;

  const AppTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns
            .map(
              (column) => DataColumn(
            label: Text(
              column,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        )
            .toList(),
        rows: rows
            .map(
              (row) => DataRow(
            cells: row.map((cell) => DataCell(Text(cell))).toList(),
          ),
        )
            .toList(),
      ),
    );
  }
}
