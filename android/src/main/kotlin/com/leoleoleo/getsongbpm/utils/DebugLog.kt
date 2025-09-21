package com.leoleoleo.getsongbpm.utils


enum class InfoType(val typeName: String) {
    GENERIC("INFO"),
    WAVEFORM("WAVEFORM"),
    JANITOR("JANITOR"),
    PERMISSION("PERMISSION"),
    MEMORY("MEMORY")
}

object DebugLog {
    private const val TAG = "[get_song_bpm]"

    fun error(message: Any?) =
        println("$TAG [ERROR] ${message ?: ""}")

    fun info(message: Any?, type: InfoType = InfoType.GENERIC) =
        println("$TAG [${type.typeName}] $message")

    fun getString(message: Any?, type: InfoType = InfoType.GENERIC) =
        "$TAG [${type.typeName}] $message"
}
