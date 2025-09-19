package com.leoleoleo.getsongbpm

import java.nio.ByteBuffer

object BpmCalculator {
    init {
        System.loadLibrary("bpm_calculator_jni")
    }

    // Declare the native method. The implementation is in C++.
    external fun calculateBpm(
        audioBuffer: ByteBuffer,
        sampleRate: Int,
        channels: Int
    ): Float
}