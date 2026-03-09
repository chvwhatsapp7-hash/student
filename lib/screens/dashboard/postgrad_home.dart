import 'package:flutter/material.dart';

class PostgradHome extends StatelessWidget {
  const PostgradHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Postgraduate Dashboard"),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const Text(
              "Welcome Postgraduate Student 📚",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Advanced Career Programs"),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Management Internships"),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Global Opportunities"),
            ),
          ],
        ),
      ),
    );
  }
}
