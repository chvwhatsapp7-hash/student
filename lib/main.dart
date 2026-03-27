import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'api_services/authservice.dart';
import 'app/router.dart';
import 'services/local_notification_service.dart';
import 'services/notification_service.dart';

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
  await AuthService().init();

  runApp(const TechPathApp());
}

class TechPathApp extends StatelessWidget {
  const TechPathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "TechPath",
      theme: ThemeData(useMaterial3: true, fontFamily: "Poppins"),
      routerConfig: router,
    );
  }
}
