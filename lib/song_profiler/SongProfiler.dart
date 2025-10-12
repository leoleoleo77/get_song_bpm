import 'dart:async';
import 'package:get_song_bpm/get_song_bpm_platform_interface.dart';
import 'audio_configs.dart';

class SongProfiler {
  final String _audioFilePath;
  final AudioConfigs? audioConfigs;

  final _isFileConverted = Completer<bool>();

  SongProfiler(
      this._audioFilePath, {
      this.audioConfigs,
  }) {
    _convertAudioInputFileToRawPCM(_audioFilePath).then((conversionResult) {
      print("_convertAudioInputFileToRawPCM completed");
      _isFileConverted.complete(conversionResult);
    });
  }

  int get _sampleRate => audioConfigs?.sampleRate ?? AudioConfigs.defaultSampleRate;

  int get _channels => audioConfigs?.channels ?? AudioConfigs.defaultChannels.value;

  Future<bool> _convertAudioInputFileToRawPCM(String audioInputPath) async {
    print("_convertAudioInputFileToRawPCM called");
    return await GetSongBpmPlatform.instance.convertAudioInputFileToRawPCM(
        audioInputPath,
        sampleRate: _sampleRate,
        channels: _channels,
    ) ?? false;
  }

  Future<double?> getBpm() async {
    final isFileConverted = await _isFileConverted.future;

    if (isFileConverted) {
      print("getBpm called");
      return await GetSongBpmPlatform.instance.getBpmFromAudioFile(_audioFilePath);
    } else {
      print("getBpm failed");
      return null;
    }
  }

  Future<List<double>?> extractWaveform({required int numPoints}) async {
    final isFileConverted = await _isFileConverted.future;

    if (isFileConverted) {
      print("extractWaveform called");
      return await GetSongBpmPlatform.instance.extractWaveform(_audioFilePath, numPoints: numPoints);
    } else {
      print("extractWaveform failed");
      return null;
    }
  }
}
