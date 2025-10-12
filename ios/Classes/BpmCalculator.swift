import Accelerate

enum BpmCalculator {

    static func calculateBpm(pcm: Data, sampleRate: Int, channels: Int) -> Double {
        guard pcm.count > 0, sampleRate > 0, channels > 0 else { return 0.0 }

        let floatSize = MemoryLayout<Float>.size
        let sampleCount = pcm.count / floatSize
        guard sampleCount > 0 else { return 0.0 }

        // Convert Data to [Float]
        var samples = [Float](repeating: 0.0, count: sampleCount)
        _ = samples.withUnsafeMutableBytes { pcm.copyBytes(to: $0) }

        // Downmix to mono
        var monoSamples: [Float]
        if channels > 1 {
            let monoCount = sampleCount / channels
            monoSamples = [Float](repeating: 0.0, count: monoCount)
            for i in 0..<monoCount {
                var sum: Float = 0.0
                for ch in 0..<channels {
                    sum += samples[i * channels + ch]
                }
                monoSamples[i] = sum / Float(channels)
            }
        } else {
            monoSamples = samples
        }

        // 🔸 Truncate to first 15 seconds
        let maxAnalysisSeconds = 15.0
        let maxSamples = min(Int(Double(sampleRate) * maxAnalysisSeconds), monoSamples.count)
        monoSamples = Array(monoSamples.prefix(maxSamples))

        // 🔸 Downsample to 4 kHz
        let downsampleFactor = max(1, sampleRate / 4000)
        let downsampledCount = monoSamples.count / downsampleFactor
        var downsampled = [Float](repeating: 0, count: downsampledCount)
        for i in 0..<downsampledCount {
            downsampled[i] = monoSamples[i * downsampleFactor]
        }

        // 🔸 Autocorrelation (still simple but much smaller data)
        let effectiveSampleRate = sampleRate / downsampleFactor
        let minBpm = 60.0
        let maxBpm = 200.0
        let minLag = Int(Double(effectiveSampleRate) * 60.0 / maxBpm)
        let maxLag = Int(Double(effectiveSampleRate) * 60.0 / minBpm)
        let lagRange = minLag..<min(maxLag, downsampled.count / 2)

        var bestLag = 0
        var maxCorr: Float = 0.0

        for lag in lagRange {
            let xSlice = downsampled[lag..<downsampled.count]
            let ySlice = downsampled[0..<downsampled.count - lag]
            let corr = dotProduct(xSlice, ySlice)
            if corr > maxCorr {
                maxCorr = corr
                bestLag = lag
            }
        }

        guard bestLag != 0 else { return 0.0 }
        let bpm = Double(effectiveSampleRate) * 60.0 / Double(bestLag)
        return max(minBpm, min(maxBpm, bpm)) * 2.0 // Adjusted BPM
    }
}

@inline(__always)
func dotProduct(_ x: ArraySlice<Float>, _ y: ArraySlice<Float>) -> Float {
    var sum: Float = 0.0
    var i = x.startIndex
    var j = y.startIndex
    while i < x.endIndex {
        sum += x[i] * y[j]
        i = x.index(after: i)
        j = y.index(after: j)
    }
    return sum
}
