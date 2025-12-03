import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('[FCM] Background message received');
  print('[FCM] Title: ${message.notification?.title}');
  print('[FCM] Body: ${message.notification?.body}');
  print('[FCM] Data: ${message.data}');
}

class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  FirebaseMessaging? _firebaseMessaging;
  FirebaseMessaging get firebaseMessaging => _firebaseMessaging ?? FirebaseMessaging.instance;
  
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Messaging
  Future<void> initialize() async {
    // Initialize Firebase Messaging instance
    _firebaseMessaging = FirebaseMessaging.instance;
    // Request permission for iOS
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('[FCM] Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('[FCM] User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('[FCM] User granted provisional permission');
    } else {
      print('[FCM] User declined or has not accepted permission');
    }

    // Initialize local notifications for Android
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await _initializeLocalNotifications();
    }

    // Get FCM token
    await _getFCMToken();

    // Listen to token refresh
    firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print('[FCM] Token refreshed: $newToken');
      // TODO: Send new token to backend
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Initialize local notifications for Android/iOS
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    if (!kIsWeb && Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'schedule_reminders', // id
        'Schedule Reminders', // name
        description: 'Notifications for upcoming schedules',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Get FCM token
  Future<void> _getFCMToken() async {
    try {
      if (kIsWeb) {
        // For web, use VAPID key
        _fcmToken = await firebaseMessaging.getToken(
          vapidKey: 'BIL1XlaE85Dgstxwiw_75NSRwQOtIDwzdNvZrVJahZxNAgfwTt3d5rUKWM__Wy4_tLmyV2t84y-x4K_VTP9r5wg',
        );
      } else {
        _fcmToken = await firebaseMessaging.getToken();
      }
      
      print('[FCM] Token: $_fcmToken');
      // TODO: Send token to backend
    } catch (e) {
      print('[FCM] Error getting token: $e');
    }
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('[FCM] Foreground message received');
    print('[FCM] Title: ${message.notification?.title}');
    print('[FCM] Body: ${message.notification?.body}');
    print('[FCM] Data: ${message.data}');

    // Show notification when app is in foreground
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await _showLocalNotification(message);
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'schedule_reminders',
            'Schedule Reminders',
            channelDescription: 'Notifications for upcoming schedules',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data['schedule_id']?.toString(),
      );
    }
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    print('[FCM] Notification tapped');
    print('[FCM] Payload: ${response.payload}');
    // TODO: Navigate to schedule detail
  }

  /// Handle message opened app (from background)
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('[FCM] Message opened app');
    print('[FCM] Data: ${message.data}');
    // TODO: Navigate to schedule detail
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await firebaseMessaging.subscribeToTopic(topic);
    print('[FCM] Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await firebaseMessaging.unsubscribeFromTopic(topic);
    print('[FCM] Unsubscribed from topic: $topic');
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    await firebaseMessaging.deleteToken();
    _fcmToken = null;
    print('[FCM] Token deleted');
  }
}


