package com.leoleoleo.getsongbpm

object SongProfilerSingleton{

    private data class SongProfiler(
        val pcmData: ByteArray
    ) {
        override fun equals(other: Any?): Boolean {
            if (this === other) return true
            if (javaClass != other?.javaClass) return false

            other as SongProfiler

            return pcmData.contentEquals(other.pcmData)
        }

        override fun hashCode(): Int {
            return pcmData.contentHashCode()
        }
    }

    private var map: MutableMap<String, SongProfiler>? = mutableMapOf()

    fun newInstance(
        filePath: String,
        pcmData: ByteArray
    ) {
        val newSongProfiler = SongProfiler(pcmData)

        if (map == null) {
            map = mutableMapOf(filePath to newSongProfiler)
        } else {
            map?.set(filePath, newSongProfiler)
        }
    }

    fun getPCMDataFor(filePath: String): ByteArray? {
        return map?.get(filePath)?.pcmData
    }
}