import 'package:flutter/material.dart';

class CommandItemData {
  final String title;
  final String? shortcut;
  final VoidCallback onTap;

  CommandItemData({
    required this.title,
    this.shortcut,
    required this.onTap,
  });
}

class CommandDialog extends StatefulWidget {
  final String title;
  final String description;
  final List<CommandItemData> items;

  const CommandDialog({
    super.key,
    this.title = "Command Palette",
    this.description = "Search for a command to run...",
    required this.items,
  });

  @override
  State<CommandDialog> createState() => _CommandDialogState();
}

class _CommandDialogState extends State<CommandDialog> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((item) =>
        item.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            /// Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 4),

            /// Description
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.description,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 12),

            /// Search Input
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search command...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),

            const SizedBox(height: 12),

            /// Command List
            SizedBox(
              height: 260,
              child: filtered.isEmpty
                  ? const Center(
                child: Text(
                  "No results found.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = filtered[index];

                  return ListTile(
                    title: Text(item.title),
                    trailing: item.shortcut != null
                        ? Text(
                      item.shortcut!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      item.onTap();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
