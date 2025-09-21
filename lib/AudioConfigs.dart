

class AudioConfigs {

  final int sampleRate;
  final int channels;

  AudioConfigs({
    required this.sampleRate,
    required this.channels
  });

  static const int _defaultSampleRate = 44100;
  static const int _defaultChannels = 2;

  static AudioConfigs get defaults {
    return AudioConfigs(
          sampleRate: _defaultSampleRate,
          channels: _defaultChannels
    );
  }
}