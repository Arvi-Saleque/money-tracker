import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../utils/helpers.dart';

abstract final class FirebaseBootstrap {
  static Future<void> initialize() async {
    if (!Helpers.supportsFirebasePlatform) {
      return;
    }

    if (kIsWeb) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return;
    }

    if (Platform.isAndroid || Platform.isIOS) {
      await Firebase.initializeApp();
    }
  }
}
