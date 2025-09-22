package com.leoleoleo.getsongbpm.utils


object DebugLog {
    private const val TAG = "[get_song_bpm]"

    fun error(message: Any?) =
        println("$TAG [ERROR] ${message ?: ""}")

    fun info(message: Any?) =
        println("$TAG [ANDROID] $message")

    fun getString(message: Any?) =
        "$TAG [ANDROID] $message"
}
