package com.leoleoleo.getsongbpm

import java.nio.ByteBuffer

object JNIRepository {
    init {
        System.loadLibrary("audio_decoder_jni")
        System.loadLibrary("bpm_calculator_jni")
        System.loadLibrary("extract_waveform_jni")
    }

    external fun decodeM4AtoPCM(
        path: Int,
        logTag: String
    ): ByteBuffer?

    external fun releaseBuffer(buffer: ByteBuffer, logTag: String)

    external fun calculateBpm(
        audioBuffer: ByteBuffer,
        bufferSize: Int,
        sampleRate: Int,
        channels: Int,
        logTag: String
    ): Float

    external fun extractWaveform(
        audioBuffer: ByteBuffer,
        bufferSize: Int,
        sampleRate: Int,
        channels: Int,
        numPoints: Int,
        logTag: String
    ): FloatArray?
}