import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              Color(0xFFF093FB)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Container(
              width: 400,
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

                  const SizedBox(height: 10),

                  const Text(
                    "🎒",
                    style: TextStyle(fontSize: 50),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Hello Explorer!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Sign in to start your tech adventure 🚀",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// EMAIL FIELD
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "📧 Your Email",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        decoration: InputDecoration(
                          hintText: "yourname@school.com",
                          filled: true,
                          fillColor: const Color(0xFFF5F3FF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// PASSWORD FIELD
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "🔒 Password",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextField(
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          hintText: "••••••••",
                          filled: true,
                          fillColor: const Color(0xFFF5F3FF),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),

                          suffixIcon: IconButton(
                            icon: Icon(
                              showPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),

                        backgroundColor: const Color(0xFF667EEA),
                      ),

                      onPressed: () {
                        context.go('/dashboard');
                      },

                      child: const Text(
                        "Let's Go!",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Text("New here? "),

                      GestureDetector(
                        onTap: () {
                          context.go('/signup');
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

                  Container(
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: Colors.yellow.shade100,
                      borderRadius: BorderRadius.circular(16),
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
        ),
      ),
    );
  }
}
