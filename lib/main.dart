import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'api_services/auth_notifier.dart';
import 'app/router.dart';
import 'services/local_notification_service.dart';
import 'services/notification_service.dart';
// ✅ FIXED: removed unused import '../screens/notifications/notification_page.dart'

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  await LocalNotificationService.init();
  await NotificationService().init();
  await AuthNotifier().init();

  runApp(const TechPathApp());
}

class TechPathApp extends StatelessWidget {
  const TechPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthNotifier(),
      builder: (context, _) {
        // ⏳ Block ALL routes from rendering until tokens are loaded.
        // This prevents the login screen flash on cold start.
        if (!AuthNotifier().isInitialized) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(useMaterial3: true, fontFamily: "Poppins"),
            home: const Scaffold(
              backgroundColor: Color(0xFF0F172A), // kInk
              body: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF38BDF8), // kAccent
                  ),
                ),
              ),
            ),
          );
        }

        // ✅ Tokens loaded → hand control to GoRouter
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: "TechPath",
          theme: ThemeData(useMaterial3: true, fontFamily: "Poppins"),
          routerConfig: router,
        );
      },
    );
  }
}
