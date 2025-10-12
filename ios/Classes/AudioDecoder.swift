import AVFoundation

enum AudioDecoder {

    static func decodeM4AToPCM(path: String) -> Data? {
        do {
            let audioFile = try AVAudioFile(forReading: URL(fileURLWithPath: path))

            let format = AVAudioFormat(
                commonFormat: .pcmFormatFloat32,
                sampleRate: audioFile.fileFormat.sampleRate,
                channels: audioFile.fileFormat.channelCount,
                interleaved: false
            )
            guard let format = format else {
                print("Error: Unable to create audio format")
                return nil
            }
            guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(audioFile.length)) else {
                print("Error: Unable to allocate PCM buffer")
                return nil
            }
            try audioFile.read(into: buffer)
            guard let channelData = buffer.floatChannelData else {
                print("Error: No channel data in buffer")
                return nil
            }
            let frameLength = Int(buffer.frameLength)
            let channelCount = Int(buffer.format.channelCount)
            var pcmData = Data()
            for frame in 0..<frameLength {
                for channel in 0..<channelCount {
                    let sample = channelData[channel][frame]
                    withUnsafeBytes(of: sample) { pcmData.append(contentsOf: $0) }
                }
            }
            return pcmData
        } catch {
            print("Error decoding audio: \(error)")
            return nil
        }
    }
}
