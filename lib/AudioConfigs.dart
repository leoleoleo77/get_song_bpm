class AudioConfigs {

  final int sampleRate;
  final AudioChannel channel;

  late final int _channels;

  AudioConfigs({
    required this.sampleRate,
    required this.channel
  }) {
    _channels = channel.value;
  }

  int get channels => _channels;

  static const int _defaultSampleRate = 44100;
  static const AudioChannel _defaultChannels = AudioChannel.mono;

  static AudioConfigs get defaults {
    return AudioConfigs(
        sampleRate: _defaultSampleRate,
        channel: _defaultChannels
    );
  }
}

enum AudioChannel {
  mono(1),
  stereo(2);

  final int value;
  const AudioChannel(this.value);
}
