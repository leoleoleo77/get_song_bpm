
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_song_bpm/song_profiler/debug_configs.dart';
import 'package:get_song_bpm/song_profiler/debug_log.dart';

import '../get_song_bpm_platform_interface.dart';
import 'audio_configs.dart';

class SongProfiler {
  final String _audioFilePath;
  final AudioConfigs? audioConfigs;
  final DebugConfigs? debugConfigs;

  final _isFileConverted = Completer<bool>();

  SongProfiler(
      this._audioFilePath, {
      this.audioConfigs,
      this.debugConfigs,
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

  int get _sampleRate => audioConfigs?.sampleRate ?? AudioConfigs.defaultSampleRate;

  int get _channels => audioConfigs?.channels ?? AudioConfigs.defaultChannels.value;

  Future<bool> _convertAudioInputFileToRawPCM(String audioInputPath) async {
    _log("Converting M4A file $_audioFilePath to raw PCM byte array...");
    return await GetSongBpmPlatform.instance.convertAudioInputFileToRawPCM(
        audioInputPath,
        sampleRate: _sampleRate,
        channels: _channels,
        isVerbose: _shouldLog,
        logTag: _debugTag
    ) ?? false;
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

  Future<List<double>?> extractWaveform({required int numPoints}) async {
    _log("extractWaveform() called with numPoints: $numPoints, waiting for the initial conversion to finish for $_audioFilePath...");
    final isFileConverted = await _isFileConverted.future;

    if (isFileConverted) {
      _log("Conversion successful, extracting waveform for $_audioFilePath...");
      return await GetSongBpmPlatform.instance.extractWaveform(_audioFilePath, numPoints: numPoints);
    } else {
      _log("Conversion failed, cannot extract waveform for $_audioFilePath.");
      return null;
    }
  }

  bool get _shouldLog => (debugConfigs?.isVerbose == true) && kDebugMode;

  String get _debugTag => _shouldLog ? "" : debugConfigs?.logTag ?? "";

  void _log(String message) {
    if (_shouldLog) DebugLog.info(message, tag: _debugTag);
  }
}
