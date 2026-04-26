import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAijEPtQJFzoz6RSz_U7vmlqabcGYLzAvw',
    appId: '1:457582135703:web:ec4fd847e03913cb779cd2',
    messagingSenderId: '457582135703',
    projectId: 'cocolytics-99fe5',
    authDomain: 'cocolytics-99fe5.firebaseapp.com',
    storageBucket: 'cocolytics-99fe5.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA7yjGcUcdp0ULMkFOG9s9GK5v-fnMaw0I',
    appId: '1:457582135703:android:b3f31265c15f6a3f779cd2',
    messagingSenderId: '457582135703',
    projectId: 'cocolytics-99fe5',
    storageBucket: 'cocolytics-99fe5.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBIfoiZzdBslz92P52orastnmjYvM3QlGQ',
    appId: '1:457582135703:ios:1829d5455d86f974779cd2',
    messagingSenderId: '457582135703',
    projectId: 'cocolytics-99fe5',
    storageBucket: 'cocolytics-99fe5.firebasestorage.app',
    iosBundleId: 'com.chanuja.cocolytics',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBIfoiZzdBslz92P52orastnmjYvM3QlGQ',
    appId: '1:457582135703:ios:98b3eef81f76db75779cd2',
    messagingSenderId: '457582135703',
    projectId: 'cocolytics-99fe5',
    storageBucket: 'cocolytics-99fe5.firebasestorage.app',
    iosBundleId: 'com.example.greenscan',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAijEPtQJFzoz6RSz_U7vmlqabcGYLzAvw',
    appId: '1:457582135703:web:056dfeaa37bac338779cd2',
    messagingSenderId: '457582135703',
    projectId: 'cocolytics-99fe5',
    authDomain: 'cocolytics-99fe5.firebaseapp.com',
    storageBucket: 'cocolytics-99fe5.firebasestorage.app',
  );
}
