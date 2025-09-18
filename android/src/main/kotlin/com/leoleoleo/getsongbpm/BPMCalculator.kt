package com.leoleoleo.getsongbpm

import java.nio.ByteBuffer

class BpmCalculator {
    // todo run on parallel thread
    companion object {
        init {
            // Load the native library on class initialization
            System.loadLibrary("bpm_calculator_jni")
        }
    }

    // Declare the native method. The implementation is in C++.
    external fun calculateBpm(
        audioBuffer: ByteBuffer,
        sampleRate: Int,
        channels: Int
    ): Float
}