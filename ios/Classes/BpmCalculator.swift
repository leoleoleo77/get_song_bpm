import Foundation
import Accelerate

enum BpmCalculator {

    // Approximate BPM (autocorrelation between 60..200 BPM)
    static func calculateBpm(pcm: Data, sampleRate: Int, channels: Int) -> Double {
        if pcm.isEmpty || sampleRate <= 0 || channels <= 0 { return -1.0 }

        // Downmix & normalize to Float
        let sampleCount = pcm.count / 2
        var floats = [Float](repeating: 0, count: sampleCount / channels)
        pcm.withUnsafeBytes { rawPtr in
            let int16Ptr = rawPtr.bindMemory(to: Int16.self)
            var writeIndex = 0
            for frame in 0..<(sampleCount / channels) {
                var acc: Int = 0
                for c in 0..<channels {
                    acc += Int(int16Ptr[frame * channels + c])
                }
                let avg = Float(acc) / Float(channels * 32768)
                floats[writeIndex] = avg
                writeIndex += 1
            }
        }

        // High-pass (simple) to emphasize transients
        var previous: Float = 0
        for i in 0..<floats.count {
            let cur = floats[i]
            floats[i] = cur - previous * 0.98
            previous = cur
        }

        // Rectify
        vDSP_vabs(floats, 1, &floats, 1, vDSP_Length(floats.count))

        // Autocorrelation for lag range
        let minBPM = 60.0
        let maxBPM = 200.0
        let minLag = Int((60.0 / maxBPM) * Double(sampleRate))
        let maxLag = Int((60.0 / minBPM) * Double(sampleRate))
        if maxLag >= floats.count { return -1.0 }

        var bestLag = minLag
        var bestVal: Float = 0
        for lag in minLag...maxLag {
            var sum: Float = 0
            var i = 0
            while i + lag < floats.count {
                sum += floats[i] * floats[i + lag]
                i += 1
            }
            if sum > bestVal {
                bestVal = sum
                bestLag = lag
            }
        }
        let bpm = 60.0 * Double(sampleRate) / Double(bestLag)
        return bpm
    }
}
