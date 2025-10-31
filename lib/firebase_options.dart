// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Archivo generado manualmente para tu proyecto
/// Puedes reemplazar los valores cuando configures tu Firebase real.
/// Por ahora funciona para pruebas.

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    } else {
      return android;
    }
  }

  // 🔥 CONFIG PARA ANDROID
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyC9-EXAMPLE-ANDROID-KEY",
    appId: "1:1234567890:android:abc123def456ghi789",
    messagingSenderId: "1234567890",
    projectId: "siba-app-test",
    storageBucket: "siba-app-test.appspot.com",
  );

  // 🌐 CONFIG PARA WEB
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyC9-EXAMPLE-WEB-KEY",
    appId: "1:1234567890:web:zzz123xxx456ccc789",
    messagingSenderId: "1234567890",
    projectId: "siba-app-test",
    authDomain: "siba-app-test.firebaseapp.com",
    storageBucket: "siba-app-test.appspot.com",
    measurementId: "G-EXAMPLE123",
  );
}
