import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'get_song_bpm_platform_interface.dart';

const String _methodChannelName = 'get_song_bpm';

class _MethodCallName {
  static String get convertM4AInputFileToRawPCMByteArray => "convertM4AInputFileToRawPCMByteArray";
  static String get getBpmFromAudioFile => "getBpmFromAudioFile";
}

class _MethodCallArgument {
  static String get filePath => "filePath";
}

/// An implementation of [GetSongBpmPlatform] that uses method channels.
class MethodChannelGetSongBpm extends GetSongBpmPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(_methodChannelName);

  @override
  Future<double?> getBpmFromAudioFile(String audioInputPath) async =>
      await methodChannel.invokeMethod<double>(
          _MethodCallName.getBpmFromAudioFile, {
            _MethodCallArgument.filePath: audioInputPath
          });

  @override
  Future<bool?> convertAudioInputFileToRawPCM(String audioInputPath) async =>
      await methodChannel.invokeMethod<bool>(
          _MethodCallName.convertM4AInputFileToRawPCMByteArray, {
        _MethodCallArgument.filePath: audioInputPath
      });
}
