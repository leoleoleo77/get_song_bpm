import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'get_song_bpm_method_channel.dart';

abstract class GetSongBpmPlatform extends PlatformInterface {
  /// Constructs a GetSongBpmPlatform.
  GetSongBpmPlatform() : super(token: _token);

  static final Object _token = Object();

  static GetSongBpmPlatform _instance = MethodChannelGetSongBpm();

  /// The default instance of [GetSongBpmPlatform] to use.
  ///
  /// Defaults to [MethodChannelGetSongBpm].
  static GetSongBpmPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GetSongBpmPlatform] when
  /// they register themselves.
  static set instance(GetSongBpmPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<double?> getBpmFromAudioFile(String audioInputPath) {
    throw UnimplementedError('getBpmFromAudioFile() has not been implemented.');
  }

  Future<bool?> convertAudioInputFileToRawPCM(
      String audioInputPath, {
      required int sampleRate,
      required int channels,
      bool isVerbose = false
  }) {
    throw UnimplementedError('convertAudioInputFileToRawPCM() has not been implemented.');
  }
}
