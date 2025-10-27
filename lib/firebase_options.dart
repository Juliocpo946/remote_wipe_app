import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web no soportado');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Plataforma no soportada');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDE7iDyffy1qWoXE4X43_sq_kJy3q8zCJU',
    appId: '1:513161749081:android:ac9495dc56b19309054748',
    messagingSenderId: '513161749081',
    projectId: 'remotewipeapp',
    storageBucket: 'remotewipeapp.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TU_IOS_API_KEY',
    appId: 'TU_IOS_APP_ID',
    messagingSenderId: 'TU_SENDER_ID',
    projectId: 'TU_PROJECT_ID',
    storageBucket: 'TU_STORAGE_BUCKET',
    iosBundleId: 'com.example.remoteWipeApp',
  );
}