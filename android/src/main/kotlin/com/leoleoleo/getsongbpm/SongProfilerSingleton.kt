package com.leoleoleo.getsongbpm

import java.nio.ByteBuffer

object SongProfilerSingleton{

    private data class SongProfiler(
        val pointerToPCMData: ByteBuffer
    )

    private var map: MutableMap<String, SongProfiler>? = mutableMapOf()

    fun newInstance(
        filePath: String,
        pointerToPCMData: ByteBuffer
    ) {
        val newSongProfiler = SongProfiler(pointerToPCMData)

        if (map == null) {
            map = mutableMapOf(filePath to newSongProfiler)
        } else {
            map?.set(filePath, newSongProfiler)
        }
    }

    fun getPointerToPCMDataFor(filePath: String): ByteBuffer? {
        return map?.get(filePath)?.pointerToPCMData
    }

    fun clear() {
        map?.forEach { (_, songProfiler) ->
            JNIRepository.releaseBuffer(songProfiler.pointerToPCMData)
        }
        map?.clear()
        map = null
    }
}