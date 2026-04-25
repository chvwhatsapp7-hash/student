import 'dart:async';
import 'package:flutter/material.dart';

class RecommendedSlider extends StatefulWidget {
  const RecommendedSlider({super.key});

  @override
  State<RecommendedSlider> createState() => _RecommendedSliderState();
}

class _RecommendedSliderState extends State<RecommendedSlider> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> data = [
    {
      "title": "Flutter Intern",
      "company": "Google",
      "color1": Colors.blue,
      "color2": Colors.purple,
      "icon": Icons.flutter_dash,
    },
    {
      "title": "Backend Developer",
      "company": "Amazon",
      "color1": Colors.orange,
      "color2": Colors.deepOrange,
      "icon": Icons.storage,
    },
    {
      "title": "UI/UX Designer",
      "company": "Adobe",
      "color1": Colors.pink,
      "color2": Colors.red,
      "icon": Icons.design_services,
    },
  ];

  @override
  void initState() {
    super.initState();

    /// 🔥 Auto Scroll
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_currentPage < data.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160, // 👈 slightly bigger than navbar
      child: PageView.builder(
        controller: _pageController,
        itemCount: data.length,
        onPageChanged: (index) {
          _currentPage = index;
        },
        itemBuilder: (context, index) {
          final item = data[index];

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              return Transform.scale(
                scale: index == _currentPage ? 1 : 0.92,
                child: child,
              );
            },
            child: _buildCard(item),
          );
        },
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [item["color1"], item["color2"]],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: item["color2"].withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [

          /// 🎯 Animated Icon
          TweenAnimationBuilder(
            tween: Tween(begin: 0.9, end: 1.1),
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value as double,
                child: child,
              );
            },
            child: Icon(
              item["icon"],
              size: 50,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 16),

          /// TEXT CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item["title"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item["company"],
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 10),

                /// 🔥 APPLY BUTTON
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Apply Now",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
