import 'package:flutter/material.dart';
import 'package:get_song_bpm/AudioConfigs.dart';
import 'dart:async';
import 'package:get_song_bpm/SongProfiler.dart';

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

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    double? bpm = null;
    double? bpm2 = null;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      final songProfiler = SongProfiler(
          "/storage/emulated/0/Android/data/com.leoleoleo.get_song_bpm_example/files/LOOP_0.m4a",
          isVerbose: true,
          audioConfigs: AudioConfigs(sampleRate: 44100, channel: AudioChannel.mono)
      );
      // final songProfiler2 = SongProfiler("/storage/emulated/0/Android/data/com.leoleoleo.get_song_bpm_example/files/AndItNeverEnds.m4a", isVerbose: true);

      bpm = await songProfiler.getBpm();
      // bpm2 = await songProfiler2.getBpm();
    } catch (e) {
      print(e);
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _bpm = bpm ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('BPM: $_bpm\n'),
        ),
      ),
    );
  }
}
