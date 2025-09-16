
import 'get_song_bpm_platform_interface.dart';

// todo: maybe change name
class GetSongBpm {
  static Future<double?> getBpmFromAudioFile(String audioInputPath) {
    return GetSongBpmPlatform.instance.getBpmFromAudioFile(audioInputPath);
  }
}
