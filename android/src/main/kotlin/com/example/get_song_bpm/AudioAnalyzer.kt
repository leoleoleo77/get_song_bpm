package com.example.get_song_bpm

import android.os.Bundle
import be.tarsos.dsp.AudioDispatcher
import be.tarsos.dsp.io.TarsosDSPAudioFormat
import be.tarsos.dsp.io.UniversalAudioInputStream
import be.tarsos.dsp.onsets.OnsetHandler
import be.tarsos.dsp.onsets.PercussionOnsetDetector
import java.io.ByteArrayInputStream
import java.util.Locale


object AudioAnalyzer {
    private val onsetTimestamps = mutableListOf<Double>()

    fun startBpmDetectionFromByteArray(audioBytes: ByteArray): Double {
        var bpm: Double = 0.0
        Thread {
            try {
                // 1. DEFINE THE AUDIO FORMAT OF YOUR BYTE ARRAY
                // This MUST match the format of your raw PCM data.
                // Common format for WAV is 44.1kHz, 16-bit, mono, signed, little-endian.
                val sampleRate = 44100.0f
                val sampleSizeInBits = 16
                val channels = 1
                val signed = true
                val bigEndian = false
                val audioFormat = TarsosDSPAudioFormat(sampleRate, sampleSizeInBits, channels, signed, bigEndian)

                // 2. CREATE THE AUDIO DISPATCHER FROM THE BYTE ARRAY
                val inputStream = ByteArrayInputStream(audioBytes)
                val audioStream = UniversalAudioInputStream(inputStream, audioFormat)

                val bufferSize = 4096
                val overlap = 1024
                val dispatcher = AudioDispatcher(audioStream, bufferSize, overlap)

                onsetTimestamps.clear()

                // 3. SETUP ONSET DETECTOR (same as before)
                val onsetHandler = OnsetHandler { time, _ -> onsetTimestamps.add(time) }
                val onsetDetector = PercussionOnsetDetector(sampleRate, bufferSize, onsetHandler, 70.0, 10.0)
                dispatcher.addAudioProcessor(onsetDetector)

                // This is a blocking call
                dispatcher.run()

                // 4. CALCULATE FINAL BPM (same as before)
                bpm = calculateBPMFromOnsets(onsetTimestamps)


            } catch (e: Exception) {
                e.printStackTrace()
            }
        }.start()

        return bpm
    }

    private fun calculateBPMFromOnsets(onsets: List<Double>): Double {
        if (onsets.size < 2) return 0.0

        val iois = (1 until onsets.size).map { onsets[it] - onsets[it - 1] }.sorted()
        if (iois.isEmpty()) return 0.0

        val medianIoi = if (iois.size % 2 == 0) {
            (iois[iois.size / 2 - 1] + iois[iois.size / 2]) / 2.0
        } else {
            iois[iois.size / 2]
        }

        return if (medianIoi > 0) 60.0 / medianIoi else 0.0
    }

    // Placeholder function to represent getting your audio data
    private fun getAudioData(): ByteArray {
        // In a real application, you would get this from your source
        // e.g., network, Bluetooth, etc.
        return ByteArray(0)
    }
}
