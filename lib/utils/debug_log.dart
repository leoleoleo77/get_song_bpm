
import 'package:flutter/foundation.dart';

enum InfoType {
  generic("INFO"),
  waveform("WAVEFORM"),
  janitor("JANITOR"),
  permission("PERMISSION"),
  memory("MEMORY");

  final String name;

  const InfoType(this.name);
}

class DebugLog {
  static const _tag = '[get_song_bpm]';

  static void error(dynamic message) {
    if (kDebugMode) {
      debugPrint('$_tag [ERROR] ${message ?? ''}');
    }
  }

  static void info(
      dynamic message, {
        InfoType type = InfoType.generic
      }) {
    if (kDebugMode && message != null) {
      debugPrint('$_tag [${type.name}] $message');
    }
  }
}