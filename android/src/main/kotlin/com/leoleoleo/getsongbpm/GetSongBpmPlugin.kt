package com.leoleoleo.getsongbpm

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.nio.ByteBuffer
import java.nio.ByteOrder

/** GetSongBpmPlugin */

private const val GET_BPM_FROM_AUDIO_FILE = "getBpmFromAudioFile"

class GetSongBpmPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "get_song_bpm")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      GET_BPM_FROM_AUDIO_FILE -> handleOnGetBpmFromAudioFile(call, result)
      else -> result.notImplemented()
    }
  }

  private fun handleOnGetBpmFromAudioFile(call: MethodCall, result: Result) {
    val audioBytes = ByteBuffer.allocate(0)

    val directBuffer = ByteBuffer.allocateDirect(0).apply {
      order(ByteOrder.nativeOrder()) // Important for correct interpretation in C++
      put(audioBytes)
      position(0) // Reset position for reading
    }


    val resultFromCpp = BpmCalculator().calculateBpm(
      audioBuffer = directBuffer,
      sampleRate = 0,
      channels = 0,
    )
    result.success(resultFromCpp) // Mocked BPM value
//    val filePath = call.argument<String>("filePath")
//    if (filePath == null) {
//      result.error("INVALID_ARGUMENT", "File path is required.", null)
//      return
//    }
  }
}
