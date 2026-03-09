import 'package:flutter/material.dart';

class CommonLoginScreen extends StatefulWidget {
  const CommonLoginScreen({super.key});

  @override
  State<CommonLoginScreen> createState() => _CommonLoginScreenState();
}

class _CommonLoginScreenState extends State<CommonLoginScreen> {
  String role = "engineering";

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool showPassword = false;

  void login() {
    if (role == "school") {
      Navigator.pushNamed(context, "/school");
    } else if (role == "engineering") {
      Navigator.pushNamed(context, "/engineering");
    } else {
      Navigator.pushNamed(context, "/postgrad");
    }
  }

  Widget roleCard(String value, String title, String emoji) {
    bool selected = role == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          role = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Colors.purple.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.purple : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                "TechPath",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              roleCard("school", "School Students", "🎒"),
              const SizedBox(height: 10),

              roleCard("engineering", "Engineering Students", "🎓"),
              const SizedBox(height: 10),

              roleCard("postgrad", "Post Graduation", "📚"),

              const SizedBox(height: 25),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: passwordController,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(showPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: login,
                  child: const Text("Sign In"),
                ),
              ),

              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/signup");
                },
                child: const Text("Create Account"),
              )
            ],
          ),
        ),
      ),
    );
  }
}