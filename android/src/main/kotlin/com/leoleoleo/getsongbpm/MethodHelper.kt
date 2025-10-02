package com.leoleoleo.getsongbpm

import java.nio.ByteBuffer
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

internal object MethodCallName {

    val convertM4AInputFileToRawPCMByteArray
        get() = "convertM4AInputFileToRawPCMByteArray"

    val getBpmFromAudioFile
        get() = "getBpmFromAudioFile"

    val extractWaveform
        get() = "extractWaveform"
}

internal object MethodCallArgument {

    val filePath
        get() = "filePath"

    val sampleRate
        get() = "sampleRate"

    val channels
        get() = "channels"

    val numPoints
        get() = "numPoints"
}

internal const val defaultSampleRate = 44100

internal const val defaultChannels = 1

internal const val defaultLogTag = ""

internal var logTag: String = defaultLogTag

internal fun handleOnConversionSuccess(
    call: MethodCall,
    result: Result,
    pointer: ByteBuffer,
    pathname: String
) {
    val sampleRate = call.argument<Int>(MethodCallArgument.sampleRate)
    val channels = call.argument<Int>(MethodCallArgument.channels)

    SongProfilerSingleton.newInstance(
        pointerToPCMData = pointer,
        filePath = pathname,
        sampleRate = sampleRate ?: defaultSampleRate,
        channels = channels ?: defaultChannels
    )
    result.success(true)
}

internal fun handleError(result: Result, error: Exception) {
    result.error("ERROR", error.message, null)
}