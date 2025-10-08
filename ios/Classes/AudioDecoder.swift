import AVFoundation

enum AudioDecoder {

    static func decodeM4AToPCM(path: String) throws -> Data {
        let url = URL(fileURLWithPath: path)
        let asset = AVURLAsset(url: url)
        guard let track = asset.tracks(withMediaType: .audio).first else {
            throw NSError(domain: "Decoder", code: -1, userInfo: [NSLocalizedDescriptionKey: "No audio track"])
        }

        let reader = try AVAssetReader(asset: asset)
        let outputSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsNonInterleaved: false
        ]
        let output = AVAssetReaderTrackOutput(track: track, outputSettings: outputSettings)
        reader.add(output)

        guard reader.startReading() else {
            throw NSError(domain: "Decoder", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to start reader"])
        }

        var pcmData = Data()
        while reader.status == .reading {
            if let sampleBuffer = output.copyNextSampleBuffer(),
               let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) {

                let length = CMBlockBufferGetDataLength(blockBuffer)
                var buffer = Data(count: length)
                buffer.withUnsafeMutableBytes { ptr in
                    _ = CMBlockBufferCopyDataBytes(blockBuffer,
                                                   atOffset: 0,
                                                   dataLength: length,
                                                   destination: ptr.baseAddress!)
                }
                pcmData.append(buffer)
                CMSampleBufferInvalidate(sampleBuffer)
            } else {
                break
            }
        }

        if reader.status == .failed {
            throw NSError(domain: "Decoder", code: -3, userInfo: [NSLocalizedDescriptionKey: reader.error?.localizedDescription ?? "Unknown decode error"])
        }
        return pcmData
    }
}
