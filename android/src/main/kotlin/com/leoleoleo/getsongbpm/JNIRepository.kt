package com.leoleoleo.getsongbpm

import java.nio.ByteBuffer

object JNIRepository {
    init {
        System.loadLibrary("audio_decoder_jni")
        System.loadLibrary("bpm_calculator_jni")
    }

    external fun decodeM4AtoPCM(path: Int): ByteArray?

    external fun calculateBpm(
        audioBuffer: ByteBuffer,
        sampleRate: Int,
        channels: Int
    ): Float
}