
import 'get_song_bpm_platform_interface.dart';

// todo: maybe change name
class GetSongBpm {
  Future<String?> getPlatformVersion() {
    return GetSongBpmPlatform.instance.getPlatformVersion();
  }

  static Future<double?> getBpmFromAudioFile(String audioInputPath) {
    return GetSongBpmPlatform.instance.getBpmFromAudioFile(audioInputPath);
  }
}
