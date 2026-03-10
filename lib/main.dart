import 'package:flutter/material.dart';
import 'app/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TechPathApp());
}

class TechPathApp extends StatelessWidget {
  const TechPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "TechPath",
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: "Poppins",
      ),
      routerConfig: router,
    );
  }
}
