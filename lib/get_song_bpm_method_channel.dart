import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'get_song_bpm_platform_interface.dart';

const String _methodChannelName = 'get_song_bpm';

class _MethodCallName {
  static String get convertM4AInputFileToRawPCMByteArray => "convertM4AInputFileToRawPCMByteArray";
  static String get getBpmFromAudioFile => "getBpmFromAudioFile";
  static String get extractWaveform => "extractWaveform";
}

class _MethodCallArgument {
  static String get filePath => "filePath";
  static String get sampleRate => "sampleRate";
  static String get channels => "channels";
  static String get isVerbose => "isVerbose";
  static String get numPoints => "numPoints";
  static String get logTag => "logTag";
}

/// An implementation of [GetSongBpmPlatform] that uses method channels.
class MethodChannelGetSongBpm extends GetSongBpmPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(_methodChannelName);

  @override
  Future<bool?> convertAudioInputFileToRawPCM(
      String audioInputPath, {
        required int sampleRate,
        required int channels,
        required bool isVerbose,
        required String logTag
      }) async =>
      await methodChannel.invokeMethod<bool>(
          _MethodCallName.convertM4AInputFileToRawPCMByteArray, {
          _MethodCallArgument.filePath: audioInputPath,
          _MethodCallArgument.sampleRate: sampleRate,
          _MethodCallArgument.channels: channels,
          _MethodCallArgument.isVerbose: isVerbose,
          _MethodCallArgument.logTag: logTag,
      });

  @override
  Future<double?> getBpmFromAudioFile(String audioInputPath) async =>
      await methodChannel.invokeMethod<double>(
          _MethodCallName.getBpmFromAudioFile, {
          _MethodCallArgument.filePath: audioInputPath
      });

  @override
  Future<List<double>?> extractWaveform(
      String audioInputPath, {
      required int numPoints,
  }) async =>
      await methodChannel.invokeMethod<List<double>>(
          _MethodCallName.extractWaveform, {
          _MethodCallArgument.filePath: audioInputPath,
          _MethodCallArgument.numPoints: numPoints,
      });
}
