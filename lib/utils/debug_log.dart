
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
  static const _tag = '[GET_SONG_BPM_DEBUG_LOG]';

  // todo: fix timestamp
  static String _timestamp() => DateTime.now().toLocal().toIso8601String().toString();

  static void error(dynamic message) {
    if (kDebugMode) {
      debugPrint('$_tag [${_timestamp()}] [ERROR] ${message ?? ''}');
    }
  }

  static void info(
      dynamic message, {
        InfoType type = InfoType.generic
      }) {
    if (kDebugMode && message != null) {
      debugPrint('$_tag [${_timestamp()}] [${type.name}] $message');
    }
  }
}