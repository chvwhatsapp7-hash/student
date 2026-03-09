import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SchoolHome extends StatelessWidget {
  const SchoolHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("School Dashboard"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const Text(
              "Welcome School Student 🎒",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                context.go('/courses');
              },
              child: const Text("View Courses"),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                context.go('/courses');
              },
              child: const Text("Coding Practice"),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {
                context.go('/courses');
              },
              child: const Text("AI & Robotics"),
            ),
          ],
        ),
      ),
    );
  }
}