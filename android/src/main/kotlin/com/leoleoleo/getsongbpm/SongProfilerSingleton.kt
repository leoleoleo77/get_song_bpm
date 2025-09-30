package com.leoleoleo.getsongbpm

import java.nio.ByteBuffer

object SongProfilerSingleton{

    private data class SongProfiler(
        val pointerToPCMData: ByteBuffer,
        val sampleRate: Int,
        val channels: Int
    )

    private var map: MutableMap<String, SongProfiler>? = mutableMapOf()

    fun newInstance(
        filePath: String,
        sampleRate: Int,
        channels: Int,
        pointerToPCMData: ByteBuffer
    ) {
        val newSongProfiler = SongProfiler(
            pointerToPCMData = pointerToPCMData,
            sampleRate = sampleRate,
            channels = channels
        )

        if (map == null) {
            map = mutableMapOf(filePath to newSongProfiler)
        } else {
            map?.set(filePath, newSongProfiler)
        }
    }

    fun getPointerToPCMDataFor(filePath: String): ByteBuffer? {
        return map?.get(filePath)?.pointerToPCMData
    }

    fun getSampleRateFor(filePath: String): Int? {
        return map?.get(filePath)?.sampleRate
    }

    fun getChannelsFor(filePath: String): Int? {
        return map?.get(filePath)?.channels
    }

    fun clear() {
        map?.forEach { (_, songProfiler) ->
            JNIRepository.releaseBuffer(songProfiler.pointerToPCMData, logTag = logTag)
        }
        map?.clear()
        map = null
    }
}