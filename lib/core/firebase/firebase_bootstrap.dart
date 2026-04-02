import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import '../utils/helpers.dart';

abstract final class FirebaseBootstrap {
  static Future<void> initialize() async {
    if (!Helpers.supportsFirebasePlatform) {
      return;
    }

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
