import 'dart:io';

import 'package:flutter/foundation.dart';

abstract final class Helpers {
  static bool get supportsFirebasePlatform {
    if (kIsWeb) {
      return true;
    }

    return Platform.isAndroid || Platform.isIOS;
  }
}
