package com.leoleoleo.getsongbpm

import java.nio.ByteBuffer

object JNIRepository {
    init {
        System.loadLibrary("audio_decoder_jni")
        System.loadLibrary("bpm_calculator_jni")
        System.loadLibrary("extract_waveform_jni")
    }

    external fun decodeM4AtoPCM(path: Int): ByteBuffer?

    external fun releaseBuffer(buffer: ByteBuffer)

    external fun calculateBpm(
        audioBuffer: ByteBuffer,
        bufferSize: Int,
        sampleRate: Int,
        channels: Int
    ): Float

    external fun extractWaveform(
        audioBuffer: ByteBuffer,
        bufferSize: Int,
        sampleRate: Int,
        channels: Int,
        numPoints: Int
    ): FloatArray?
}