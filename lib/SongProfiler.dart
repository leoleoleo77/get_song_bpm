
import 'dart:async';

import 'package:get_song_bpm/AudioConfigs.dart';
import 'package:get_song_bpm/utils/debug_log.dart';

import 'get_song_bpm_platform_interface.dart';

class SongProfiler {
  final String _audioFilePath;
  final AudioConfigs audioConfigs;
  final bool isVerbose;

  final _isFileConverted = Completer<bool>();

  SongProfiler(
      this._audioFilePath, {
      required this.audioConfigs,
      this.isVerbose = false // todo
  }) {
    _convertAudioInputFileToRawPCM(_audioFilePath).then((conversionResult) {
      _isFileConverted.complete(conversionResult);

      if (conversionResult) {
        _log("Conversion successful, creating SongProfiler for: $_audioFilePath");
      } else {
        _log("Conversion failed for: $_audioFilePath");
      }
    });
  }

  Future<bool> _convertAudioInputFileToRawPCM(String audioInputPath) async {
    _log("Converting M4A file $_audioFilePath to raw PCM byte array...");
    return await GetSongBpmPlatform.instance.convertAudioInputFileToRawPCM(audioInputPath) ?? false;
  }

  Future<double?> getBpm() async {
    _log("getBpm() called, waiting for the initial conversion to finish for $_audioFilePath...");
    final isFileConverted = await _isFileConverted.future;

    if (isFileConverted) {
      _log("Conversion successful, calculating BPM for $_audioFilePath...");
      return await GetSongBpmPlatform.instance.getBpmFromAudioFile(_audioFilePath);
    } else {
      _log("Conversion failed, cannot get BPM for $_audioFilePath.");
      return null;
    }
  }

  void _log(String message) {
    if (isVerbose) DebugLog.info(message);
  }
}
