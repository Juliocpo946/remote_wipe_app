import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'data_manager.dart';
import 'logger.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['action'] == 'wipe') {
    await DataManager.instance.wipeAllData();
  }
}

class FirebaseService {
  static final FirebaseService instance = FirebaseService._();
  FirebaseService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  String? _token;
  String? get token => _token;

  Future<void> initialize() async {
    await _requestPermission();
    await _setupNotifications();
    await _getToken();
    _setupMessageHandlers();
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      Logger.error('firebase_service', 'Permiso de notificaciones denegado', 'PERM_001');
    }
  }

  Future<void> _setupNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(settings);
  }

  Future<void> _getToken() async {
    try {
      _token = await _messaging.getToken();
    } catch (e) {
      Logger.error('firebase_service', 'Error obteniendo token FCM', 'TOKEN_001');
    }
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      if (message.data['action'] == 'wipe') {
        DataManager.instance.wipeAllData();
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data['action'] == 'wipe') {
        DataManager.instance.wipeAllData();
      }
    });
  }
}