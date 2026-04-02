// File generated manually from Firebase CLI app configuration.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC1k0kYaiowgRXNDXUZ9Vk6XI6n-FhPC0w',
    appId: '1:249670635146:web:aaa82de19592a284036773',
    messagingSenderId: '249670635146',
    projectId: 'money-tracker-codex-2026',
    authDomain: 'money-tracker-codex-2026.firebaseapp.com',
    storageBucket: 'money-tracker-codex-2026.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDEi0EBjAkMp-648LlLOoM2Zl3IEytJ9oA',
    appId: '1:249670635146:android:04a6d70b69a9ae43036773',
    messagingSenderId: '249670635146',
    projectId: 'money-tracker-codex-2026',
    storageBucket: 'money-tracker-codex-2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDT3O05uGfASnd5fEeleNjCVdBM8ITL_r4',
    appId: '1:249670635146:ios:2540687d014731df036773',
    messagingSenderId: '249670635146',
    projectId: 'money-tracker-codex-2026',
    storageBucket: 'money-tracker-codex-2026.firebasestorage.app',
    iosBundleId: 'com.codex.moneytracker.moneyTracker',
  );
}
