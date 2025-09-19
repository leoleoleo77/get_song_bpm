package com.leoleoleo.getsongbpm

object AudioDecoder {
    init {
        System.loadLibrary("audio_decoder_jni")
    }

    external fun decodeM4AtoPCM(path: Int): ByteArray?
}