// Reemplaza este archivo ejecutando: dart pub global activate flutterfire_cli && flutterfire configure
// Los valores deben coincidir con tu proyecto en Firebase Console.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Opciones de Firebase por plataforma (plantilla para QuickMarket).
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
        throw UnsupportedError(
          'DefaultFirebaseOptions no está definido para Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está definido para Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está definido para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyALRh-6lM-j9HmapOA5JEJRh4UuIjTUFIE',
    appId: '1:77736679035:web:c75a71ecfc4205a79e74de',
    messagingSenderId: '77736679035',
    projectId: 'quickmarket-a9eef',
    authDomain: 'quickmarket-a9eef.firebaseapp.com',
    storageBucket: 'quickmarket-a9eef.firebasestorage.app',
    measurementId: 'G-BWJX55LXGN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVrQY9TiltDpPJASYcI2aA3sMFOCpAYis',
    appId: '1:77736679035:android:792b2dcdec7fee3a9e74de',
    messagingSenderId: '77736679035',
    projectId: 'quickmarket-a9eef',
    storageBucket: 'quickmarket-a9eef.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_IOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'quickmarket-demo',
    storageBucket: 'quickmarket-demo.appspot.com',
    iosBundleId: 'com.quickmarket.quickmarket',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_MACOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'quickmarket-demo',
    storageBucket: 'quickmarket-demo.appspot.com',
    iosBundleId: 'com.quickmarket.quickmarket',
  );
}