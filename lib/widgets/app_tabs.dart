import 'package:flutter/material.dart';

class AppTabs extends StatelessWidget {
  final List<String> tabs;
  final List<Widget> pages;

  const AppTabs({
    super.key,
    required this.tabs,
    required this.pages,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: TabBarView(
              children: pages,
            ),
          ),
        ],
      ),
    );
  }
}
