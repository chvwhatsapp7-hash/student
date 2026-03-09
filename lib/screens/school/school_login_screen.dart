import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SchoolLoginScreen extends StatefulWidget {
  const SchoolLoginScreen({super.key});

  @override
  State<SchoolLoginScreen> createState() => _SchoolLoginScreenState();
}

class _SchoolLoginScreenState extends State<SchoolLoginScreen>
    with TickerProviderStateMixin {

  bool showPass = false;

  final List<String> emojis = [
    '🚀','🤖','💻','🎮','⭐','🌈','🔬','🎯'
  ];

  final List<String> shapes = [
    '🟣','🟡','🔵','🟢','🔴','🟠'
  ];

  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [

          /// Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff667eea),
                  Color(0xff764ba2),
                  Color(0xfff093fb)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// Floating Emojis
          ...List.generate(emojis.length, (i) {
            return AnimatedBuilder(
              animation: controller,
              builder: (_, child) {

                double offset = sin(controller.value * 2 * pi + i) * 20;

                return Positioned(
                  left: 30 + i * 40,
                  top: 80 + offset + (i % 3) * 120,
                  child: Text(
                    emojis[i],
                    style: const TextStyle(fontSize: 30),
                  ),
                );
              },
            );
          }),

          /// Floating Shapes
          ...List.generate(shapes.length, (i) {
            return AnimatedBuilder(
              animation: controller,
              builder: (_, child) {

                double rotate = controller.value * 2 * pi;

                return Positioned(
                  right: 20 + i * 35,
                  bottom: 60 + (i % 3) * 100,
                  child: Transform.rotate(
                    angle: rotate,
                    child: Opacity(
                      opacity: .3,
                      child: Text(
                        shapes[i],
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          /// Main content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 360,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black26,
                    )
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    /// Backpack emoji
                    const Text(
                      "🎒",
                      style: TextStyle(fontSize: 50),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Hello Explorer!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      "Sign in to start your tech adventure 🚀",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    /// Stars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                            (index) => const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          child: Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 22,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// Email
                    TextField(
                      decoration: InputDecoration(
                        labelText: "📧 Your Email",
                        filled: true,
                        fillColor: const Color(0xfff5f0ff),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// Password
                    TextField(
                      obscureText: !showPass,
                      decoration: InputDecoration(
                        labelText: "🔒 Password",
                        filled: true,
                        fillColor: const Color(0xfff5f0ff),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPass
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              showPass = !showPass;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Login Button
                    GestureDetector(
                      onTap: () {
                        context.go("/school/dashboard");
                        /// Navigator.pushNamed(context, "/school");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff667eea),
                              Color(0xff764ba2),
                            ],
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Let's Go!",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward,color: Colors.white)
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Signup
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        const Text("New here? "),

                        GestureDetector(
                          onTap: (){
                            Navigator.pushNamed(context,"/school/signup");
                          },
                          child: const Text(
                            "Join the Fun!",
                            style: TextStyle(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// Parents note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.yellow),
                      ),
                      child: const Text(
                        "👨‍👩‍👧 Parents: Please help your child register. Sunday is a holiday!",
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    )

                  ],
                ),
              ),
            ),
          )

        ],
      ),
    );
  }
}