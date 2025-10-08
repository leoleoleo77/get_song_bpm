import Flutter
import AVFoundation


private let methodChannelName = "get_song_bpm"

public class GetSongBpmPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: registrar.messenger())
        let instance = GetSongBpmPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "convertM4AInputFileToRawPCMByteArray":
            guard let args = call.arguments as? [String: Any],
                  let filePath = args["filePath"] as? String,
                  !filePath.isEmpty else {
                result(FlutterError(code: "ARG_ERROR", message: "filePath missing", details: nil))
                return
            }
            let sampleRate = (args["sampleRate"] as? Int) ?? 44100
            let channels = (args["channels"] as? Int) ?? 1

            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let decoded = try AudioDecoder.decodeM4AToPCM(path: filePath)
                    // Store pointer (Data) with provided override metadata (mirrors Android storing passed params)
                    SongProfilerSingleton.newInstance(
                        filePath: filePath,
                        sampleRate: sampleRate,
                        channels: channels,
                        pcmData: decoded
                    )
                    result(true)
                } catch {
                    result(FlutterError(code: "DECODE_ERROR", message: error.localizedDescription, details: nil))
                }
            }

        case "getBpmFromAudioFile":
            guard let args = call.arguments as? [String: Any],
                  let filePath = args["filePath"] as? String,
                  !filePath.isEmpty else {
                result(FlutterError(code: "ARG_ERROR", message: "filePath missing", details: nil))
                return
            }
            DispatchQueue.global(qos: .userInitiated).async {
                guard let profiler = SongProfilerSingleton.get(for: filePath) else {
                    result(FlutterError(code: "STATE_ERROR", message: "PCM not found. Call convert first.", details: nil))
                    return
                }
                let bpm = BpmCalculator.calculateBpm(
                    pcm: profiler.pcmData,
                    sampleRate: profiler.sampleRate,
                    channels: profiler.channels
                )
                result(bpm)
            }

        case "extractWaveform":
            guard let args = call.arguments as? [String: Any],
                  let filePath = args["filePath"] as? String,
                  let numPoints = args["numPoints"] as? Int,
                  numPoints > 0 else {
                result(FlutterError(code: "ARG_ERROR", message: "filePath/numPoints invalid", details: nil))
                return
            }
            DispatchQueue.global(qos: .userInitiated).async {
                guard let profiler = SongProfilerSingleton.get(for: filePath) else {
                    result(FlutterError(code: "STATE_ERROR", message: "PCM not found", details: nil))
                    return
                }
                let waveform = WaveformExtractor.extract(
                    pcm: profiler.pcmData,
                    sampleRate: profiler.sampleRate,
                    channels: profiler.channels,
                    numPoints: numPoints
                )
                result(waveform)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    deinit {
        SongProfilerSingleton.clear()
    }
}
