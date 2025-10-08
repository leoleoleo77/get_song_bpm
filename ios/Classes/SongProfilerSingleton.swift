import Foundation

struct SongProfiler {
    let pcmData: Data          // 16-bit signed interleaved
    let sampleRate: Int
    let channels: Int
}

enum SongProfilerSingleton {
    private static var map: [String: SongProfiler] = [:]
    private static let lock = NSLock()

    static func newInstance(filePath: String,
                            sampleRate: Int,
                            channels: Int,
                            pcmData: Data) {
        lock.lock()
        map[filePath] = SongProfiler(pcmData: pcmData,
                                     sampleRate: sampleRate,
                                     channels: channels)
        lock.unlock()
    }

    static func get(for filePath: String) -> SongProfiler? {
        lock.lock()
        let v = map[filePath]
        lock.unlock()
        return v
    }

    static func clear() {
        lock.lock()
        map.removeAll()
        lock.unlock()
    }
}
