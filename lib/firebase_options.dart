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

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _require('FIREBASE_WEB_API_KEY'),
    appId: _require('FIREBASE_WEB_APP_ID'),
    messagingSenderId: _require('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _require('FIREBASE_PROJECT_ID'),
    authDomain: _require('FIREBASE_AUTH_DOMAIN'),
    storageBucket: _require('FIREBASE_STORAGE_BUCKET'),
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _require('FIREBASE_ANDROID_API_KEY'),
    appId: _require('FIREBASE_ANDROID_APP_ID'),
    messagingSenderId: _require('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _require('FIREBASE_PROJECT_ID'),
    storageBucket: _require('FIREBASE_STORAGE_BUCKET'),
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _require('FIREBASE_IOS_API_KEY'),
    appId: _require('FIREBASE_IOS_APP_ID'),
    messagingSenderId: _require('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _require('FIREBASE_PROJECT_ID'),
    storageBucket: _require('FIREBASE_STORAGE_BUCKET'),
    iosBundleId: _require('FIREBASE_IOS_BUNDLE_ID'),
  );

  static String _require(String key) {
    final value = String.fromEnvironment(key);
    if (value.isEmpty) {
      throw UnsupportedError(
        'Missing Firebase configuration for $key. '
        'Provide it with --dart-define or local platform Firebase config files.',
      );
    }
    return value;
  }
}
