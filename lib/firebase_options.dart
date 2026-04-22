import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError('Platform not supported.');
    }
  }

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: dotenv.get('FIREBASE_WEB_API_KEY'),
    appId: '1:457582135703:web:ec4fd847e03913cb779cd2',
    messagingSenderId: '457582135703',
    projectId: 'cocolytics-99fe5',
    authDomain: 'cocolytics-99fe5.firebaseapp.com',
    storageBucket: 'cocolytics-99fe5.firebasestorage.app',
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: dotenv.get('FIREBASE_ANDROID_API_KEY'),
    appId: '1:457582135703:android:b3f31265c15f6a3f779cd2',
    messagingSenderId: '457582135703',
    projectId: 'cocolytics-99fe5',
    storageBucket: 'cocolytics-99fe5.firebasestorage.app',
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: dotenv.get('FIREBASE_IOS_API_KEY'),
    appId: '1:457582135703:ios:1829d5455d86f974779cd2',
    messagingSenderId: '457582135703',
    projectId: 'cocolytics-99fe5',
    storageBucket: 'cocolytics-99fe5.firebasestorage.app',
    iosBundleId: 'com.sasudul.cocolytics',
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: dotenv.get('FIREBASE_IOS_API_KEY'),
    appId: '1:457582135703:ios:98b3eef81f76db75779cd2',
    messagingSenderId: '457582135703',
    projectId: 'cocolytics-99fe5',
    storageBucket: 'cocolytics-99fe5.firebasestorage.app',
    iosBundleId: 'com.example.greenscan',
  );

  static FirebaseOptions get windows => FirebaseOptions(
    apiKey: dotenv.get('FIREBASE_WEB_API_KEY'),
    appId: '1:457582135703:web:056dfeaa37bac338779cd2',
    messagingSenderId: '457582135703',
    projectId: 'cocolytics-99fe5',
    authDomain: 'cocolytics-99fe5.firebaseapp.com',
    storageBucket: 'cocolytics-99fe5.firebasestorage.app',
  );
}