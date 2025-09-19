
import 'dart:async';

import 'package:get_song_bpm/utils/debug_log.dart';

import 'get_song_bpm_platform_interface.dart';

class SongProfiler {
  final String _audioFilePath;
  final bool isVerbose;

  final _isFileConverted = Completer<bool>();

  SongProfiler(
      this._audioFilePath, {
      this.isVerbose = false // todo
  }) {
    if (isVerbose) DebugLog.info("Creating SongProfiler for $_audioFilePath...");

    _convertAudioInputFileToRawPCM(_audioFilePath).then((conversionResult) {
      _isFileConverted.complete(conversionResult);

      if (isVerbose) {
        if (conversionResult) {
          DebugLog.info("Successfully created SongProfiler for: $_audioFilePath");
        } else {
          DebugLog.error("Failed to create SongProfiler for: $_audioFilePath");
        }
      }
    });
  }


  Future<bool> _convertAudioInputFileToRawPCM(String audioInputPath) async =>
      await GetSongBpmPlatform.instance.convertAudioInputFileToRawPCM(audioInputPath) ?? false;

  Future<double?> getBpm() async {
    if (isVerbose) DebugLog.info("getBpm() called, waiting for the initial conversion to finish for $_audioFilePath...");
    final isFileConverted = await _isFileConverted.future;

    if (isFileConverted) {
      if (isVerbose) DebugLog.info("Conversion successful! Getting BPM for $_audioFilePath...");
      return await GetSongBpmPlatform.instance.getBpmFromAudioFile(_audioFilePath);
    } else {
      if (isVerbose) DebugLog.info("Conversion failed! Cannot get BPM for $_audioFilePath.");
      return null;
    }
  }
}
