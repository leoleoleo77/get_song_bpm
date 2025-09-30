import 'package:flutter/material.dart';
import 'package:get_song_bpm/song_profiler/audio_configs.dart';
import 'dart:async';
import 'package:get_song_bpm/song_profiler/SongProfiler.dart';
import 'package:get_song_bpm/song_profiler/debug_configs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _bpm = 0;
  int _waveform = 0;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    double? bpm = null;
    List<double>? waveform = null;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      final songProfiler = SongProfiler(
          "/storage/emulated/0/Android/data/com.leoleoleo.get_song_bpm_example/files/LOOP_0.m4a",
          audioConfigs: AudioConfigs(
              sampleRate: AudioConfigs.defaultSampleRate,
              channel: AudioConfigs.defaultChannels,
          ),
          debugConfigs: DebugConfigs(
            isVerbose: false,
            logTag: "[GetSongBpmExample]",
        )
      );
      // final songProfiler2 = SongProfiler("/storage/emulated/0/Android/data/com.leoleoleo.get_song_bpm_example/files/AndItNeverEnds.m4a", isVerbose: true);

      bpm = await songProfiler.getBpm();
      waveform = await  songProfiler.extractWaveform(numPoints: 100);
    } catch (e) {
      print(e);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _bpm = bpm ?? 0;
      _waveform = waveform?.length ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Text('BPM: $_bpm\n'),
              Text('Waveform: $_waveform\n'),
            ],
          ),
        ),
      ),
    );
  }
}
