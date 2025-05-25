import 'dart:convert';

import 'package:project_skripsi/screen/auth/login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class NotificationApi {
  static int notificationId = 0;
  static String fCMToken = "";
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel(
      'high_importance_channel', 'High Importance Notifications',
      description: 'This channel is used for important notification',
      importance: Importance.high);

  final _localNotifications = FlutterLocalNotificationsPlugin();

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    moveOtherScreen(message);
    // ?.pushNamed(ItemScreen.route, arguments: message);
  }

  Future initLocalNotifications() async {
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@drawable/launcher_icon');
    const settings = InitializationSettings(android: android, iOS: iOS);
    await _localNotifications.initialize(settings,
        onDidReceiveNotificationResponse: (payload) {
      final message = RemoteMessage.fromMap(jsonDecode(payload.payload!));
      moveOtherScreen(message);
    });
    final platform = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidChannel);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@drawable/launcher_icon',
          )),
          payload: jsonEncode(message.toMap()));
    });
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    fCMToken = (await _firebaseMessaging.getToken())!;

    initPushNotifications();
    initLocalNotifications();
  }

  void moveOtherScreen(
    RemoteMessage message,
  ) {
    print(message);
    notificationId = int.parse(message.data['id']);
    Get.to(LoginScreen());
  }
}
