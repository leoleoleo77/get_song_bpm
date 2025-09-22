
import 'package:flutter/foundation.dart';

class DebugLog {
  static const _tag = '[get_song_bpm]';

  static void info(dynamic message) {
    if (message != null) {
      debugPrint('$_tag [FLUTTER] $message');
    }
  }
}