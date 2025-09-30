
import 'package:flutter/foundation.dart';

class DebugLog {

  static void info(
      dynamic message, {
      required String tag
  }) {
    if (message != null) {
      debugPrint('$tag [FLUTTER] $message');
    }
  }
}