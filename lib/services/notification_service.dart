import 'package:firebase_messaging/firebase_messaging.dart';
import 'local_notification_service.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // Request permission
    await _firebaseMessaging.requestPermission();

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print("FCM TOKEN: $token");

    // Foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      LocalNotificationService.showNotification(
        message.notification?.title ?? "No Title",
        message.notification?.body ?? "No Body",
      );
    });

    // When user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("Notification clicked!");
    });
  }
}