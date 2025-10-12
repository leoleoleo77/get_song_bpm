import Foundation

enum WaveformExtractor {

    static func extract(
        pcm: Data,
        sampleRate: Int,
        channels: Int,
        numPoints: Int
    ) -> [Double] {
        if pcm.isEmpty || numPoints <= 0 || channels <= 0 { return [] }

        let totalSamples = pcm.count / 2
        let totalFrames = totalSamples / channels
        if totalFrames == 0 { return [] }

        let framesPerPoint = max(1, totalFrames / numPoints)
        var peaks = [Double](repeating: 0, count: numPoints)  // 👈 Double array

        pcm.withUnsafeBytes { rawPtr in
            let samples = rawPtr.bindMemory(to: Int16.self)
            for p in 0..<numPoints {
                let startFrame = p * framesPerPoint
                if startFrame >= totalFrames { break }
                let endFrame = min(totalFrames, startFrame + framesPerPoint)
                var peak: Double = 0  // 👈 Double peak
                for f in startFrame..<endFrame {
                    for c in 0..<channels {
                        let s = samples[f * channels + c]
                        let v = abs(Double(s) / 32768.0)  // 👈 cast to Double once
                        if v > peak { peak = v }
                    }
                }
                peaks[p] = peak
            }
        }
        return peaks
    }
}

