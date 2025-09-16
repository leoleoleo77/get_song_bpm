import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'get_song_bpm_platform_interface.dart';

/// An implementation of [GetSongBpmPlatform] that uses method channels.
class MethodChannelGetSongBpm extends GetSongBpmPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('get_song_bpm');

  @override
  Future<double?> getBpmFromAudioFile(String audioInputPath) async {
    final bpm = await methodChannel.invokeMethod<double>('getBpmFromAudioFile');
    return bpm;
  }
}
