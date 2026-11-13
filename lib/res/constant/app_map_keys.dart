import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppMapKeys {
  const AppMapKeys._();

  static const String androidKey = "AIzaSyBDoZWzDdhnnXe0Kuaz0qcPZT_vsUltoxo";
  static const String iosKey = "AIzaSyDWTIoANjvo1nKkig_yiCHgxICxWNPvIpc";

  /// Returns the appropriate Google Maps API key depending on current platform.
  static String get apiKey {
    if (!kIsWeb && Platform.isIOS) {
      return iosKey;
    }
    return androidKey;
  }
}

