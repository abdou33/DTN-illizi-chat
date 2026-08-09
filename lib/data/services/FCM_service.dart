import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static String? token;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'chat_messages_v2',
    'Chat Messages',
    description: 'Notifications for new DTN Chat messages',
    importance: Importance.max,
    playSound: true,
  );

  static Future<void> initialize() async {
    await _requestPermission();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    await _notifications.initialize(
      settings: const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    token = await _messaging.getToken();

    if (kDebugMode) {
      print('FCM TOKEN: $token');
    }

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      token = newToken;

      if (kDebugMode) {
        print('FCM TOKEN REFRESHED: $newToken');
      }

      // Send newToken to Laravel here if needed.
    });
  }

  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      print('Notification permission: ${settings.authorizationStatus}');
    }
  }

  // App is OPEN
  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      print('FCM foreground: ${message.data}');
    }

    await _showNotification(message, sound: false);
  }

  // App is BACKGROUND and notification is tapped
  static void _onMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('FCM opened: ${message.data}');
    }

    _handleNotificationData(message.data);
  }

  // App was COMPLETELY CLOSED and notification is tapped
  static Future<void> handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();

    if (message != null) {
      _handleNotificationData(message.data);
    }

    final launchDetails = await _notifications
        .getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp == true) {
      final payload = launchDetails?.notificationResponse?.payload;

      if (payload != null) {
        _handleNotificationData(jsonDecode(payload));
      }
    }
  }

  static Future<void> _showNotification(
    RemoteMessage message, {
    required bool sound,
  }) async {
    final notification = message.notification;

    final title = notification?.title ?? message.data['title'] ?? 'New message';

    final body =
        notification?.body ?? message.data['body'] ?? 'You have a new message';

    await _notifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_messages_v2',
          'Chat Messages',
          channelDescription: 'DTN Chat message notifications',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;

    final data = jsonDecode(response.payload!);

    _handleNotificationData(Map<String, dynamic>.from(data));
  }

  static void _handleNotificationData(Map<String, dynamic> data) {
    if (kDebugMode) {
      print('Notification data: $data');
    }

    final conversationId = data['conversation_id'];

    if (conversationId == null) return;

    // Navigate to ConversationScreen here.
    //
    // Example:
    // navigatorKey.currentState?.push(...);
  }

  static Future<String?> getToken() async {
    token ??= await _messaging.getToken();
    return token;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (kDebugMode) {
    print('FCM BACKGROUND: ${message.data}');
  }
}
