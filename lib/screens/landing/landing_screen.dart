import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Row(
                    children: const [
                      Icon(Icons.code, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        "TechPath",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [

                      TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: const Text("Sign In"),
                      ),

                      ElevatedButton(
                        onPressed: () {
                          context.go('/signup');
                        },
                        child: const Text("Get Started"),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// HERO SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: const [

                  Text(
                    "Your Tech Journey Starts Here",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 16),

                  Text(
                    "Connecting engineering students with top tech companies and inspiring young minds with programming.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// HERO BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text("Launch Your Career"),
                ),

                const SizedBox(width: 10),

                OutlinedButton(
                  onPressed: () {
                    context.go('/login');
                  },
                  child: const Text("Learn to Code"),
                )
              ],
            ),

            const SizedBox(height: 50),

            /// PORTAL CARDS
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  /// ENGINEERING CARD
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: ListTile(
                      leading: const Icon(Icons.school, size: 40),

                      title: const Text(
                        "Engineering Students",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: const Text(
                        "Discover jobs, internships and companies across India.",
                      ),

                      trailing: const Icon(Icons.arrow_forward),

                      onTap: () {
                        context.go('/engineering');   // ✅ FIXED
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SCHOOL CARD
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: ListTile(
                      leading: const Icon(Icons.rocket_launch, size: 40),

                      title: const Text(
                        "School Students",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

                      subtitle: const Text(
                        "Learn coding, AI, robotics and fun summer programs.",
                      ),

                      trailing: const Icon(Icons.arrow_forward),

                      onTap: () {
                        context.go('/school');   // ✅ FIXED
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// STATS SECTION
            Container(
              color: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 40),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [

                  Column(
                    children: [
                      Text(
                        "2400+",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Students", style: TextStyle(color: Colors.white70)),
                    ],
                  ),

                  Column(
                    children: [
                      Text(
                        "180+",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Companies",
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),

                  Column(
                    children: [
                      Text(
                        "50+",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("Courses",
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            /// FOOTER
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(20),

              child: const Column(
                children: [

                  Text(
                    "TechPath",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "© 2025 TechPath. Built for India's next generation of tech innovators.",
                    style: TextStyle(color: Colors.white60),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
