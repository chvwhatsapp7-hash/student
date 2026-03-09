import 'package:flutter/material.dart';

class CommonSignupScreen extends StatefulWidget {
  const CommonSignupScreen({super.key});

  @override
  State<CommonSignupScreen> createState() => _CommonSignupScreenState();
}

class _CommonSignupScreenState extends State<CommonSignupScreen> {
  String role = "engineering";

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  bool showPassword = false;

  void signup() {
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
      appBar: AppBar(title: const Text("Create Account")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            roleCard("school", "School Students", "🎒"),
            const SizedBox(height: 10),

            roleCard("engineering", "Engineering Students", "🎓"),
            const SizedBox(height: 10),

            roleCard("postgrad", "Post Graduation", "📚"),

            const SizedBox(height: 25),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Phone",
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
                onPressed: signup,
                child: const Text("Create Account"),
              ),
            )
          ],
        ),
      ),
    );
  }
}