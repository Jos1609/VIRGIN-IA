import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Web
      return web;
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      // iOS and macOS
      return ios;
    } else {
      // Android
      return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyAWThqwFF6hkWEM6LWeuzfwHCgcQk8vbd8",
    authDomain: "virgin-ia-28f40.firebaseapp.com",
    projectId: "virgin-ia-28f40",
    storageBucket: "virgin-ia-28f40.appspot.com",
    messagingSenderId: "299681730048",
    appId: "1:299681730048:web:5871c4e618e638fdf192e5",
    measurementId: "G-XE67C67PZM",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyAWThqwFF6hkWEM6LWeuzfwHCgcQk8vbd8",
    authDomain: "virgin-ia-28f40.firebaseapp.com",
    projectId: "virgin-ia-28f40",
    storageBucket: "virgin-ia-28f40.appspot.com",
    messagingSenderId: "299681730048",
    appId: "1:299681730048:web:5871c4e618e638fdf192e5",
    measurementId: "G-XE67C67PZM",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyAWThqwFF6hkWEM6LWeuzfwHCgcQk8vbd8",
    authDomain: "virgin-ia-28f40.firebaseapp.com",
    projectId: "virgin-ia-28f40",
    storageBucket: "virgin-ia-28f40.appspot.com",
    messagingSenderId: "299681730048",
    appId: "1:299681730048:web:5871c4e618e638fdf192e5",
    measurementId: "G-XE67C67PZM",
  );
}
