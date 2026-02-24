import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await _setupLocalNotifications();
    await _setupFCM();
  }

  static Future<void> _setupLocalNotifications() async {
    const androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidInit);

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("🔔 Notification clicked in foreground/background: ${response.payload}");
      },
    );

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔔 User granted permission: ${settings.authorizationStatus}');

    String? token = await messaging.getToken();
    print("📱 FCM Device Token: $token");

    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print("🚀 App started from terminated state via notification: ${initialMessage.data}");
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground Message received: ${message.notification?.title}");

      String title = message.notification?.title ??
          message.data["title"] ??
          "Notification";

      String body = message.notification?.body ??
          message.data["body"] ??
          "";

      _showLocalNotification(title, body);
    });

    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🔔 App opened from notification while in background: ${message.data}");
    });
  }

  static Future<void> _showLocalNotification(
      String title, String body) async {

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background tasks
  await Firebase.initializeApp();
  print("📩 Handling a background message: ${message.messageId}");
  // Note: Local notifications are usually shown automatically by the OS 
  // if the payload contains a 'notification' object. 
  // If it only contains 'data', you might need to show it manually here if desired.
}