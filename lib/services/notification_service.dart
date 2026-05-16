import 'package:firebase_messaging/firebase_messaging.dart';
import '../app/router.dart'; // adjust path if needed
import 'local_notification_service.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _firebaseMessaging.requestPermission();

    String? token = await _firebaseMessaging.getToken();
    print("FCM TOKEN: $token");

    // Foreground: show local notification banner
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LocalNotificationService.showNotification(
        message.notification?.title ?? "No Title",
        message.notification?.body ?? "No Body",
      );
    });

    // App in background → user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message);
    });

    // App fully killed → user taps notification that launched the app
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      // Slight delay to let GoRouter finish initialising
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationTap(initialMessage);
      });
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    // You can check message.data to route differently per notification type
    // e.g. if (message.data['type'] == 'job') router.go('/jobs');
    router.go('/school/notifications');
  }
}