package com.leoleoleo.getsongbpm

// Flutter imports
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

// Coroutine imports
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel

private const val methodChannelName = "get_song_bpm"

class GetSongBpmPlugin: FlutterPlugin, MethodCallHandler {

  private lateinit var channel : MethodChannel

  private val scope = CoroutineScope(Dispatchers.Main)

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, methodChannelName)
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    scope.cancel()
    SongProfilerSingleton.clear()
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {

      MethodCallName.convertM4AInputFileToRawPCMByteArray -> {
        logTag = call.argument<String>(MethodCallArgument.logTag) ?: defaultLogTag // Set log tag if provided
        MethodCallRepository.convertM4AInputFileToRawPCMByteArray(
          scope = scope,
          pathname = call.argument<String>(MethodCallArgument.filePath),
          onSuccess = { pointer, pathname -> handleOnConversionSuccess(call, result, pointer, pathname) },
          onError = { handleError(result, it) }
        )
      }

      MethodCallName.getBpmFromAudioFile ->  {
        MethodCallRepository.getBpmFromAudioFile(
          scope = scope,
          pathname = call.argument<String>(MethodCallArgument.filePath),
          onSuccess = { bpm -> result.success(bpm) },
          onError = { handleError(result, it) }
        )
      }

      MethodCallName.extractWaveform -> {
        MethodCallRepository.extractWaveform(
          scope = scope,
          pathname = call.argument<String>(MethodCallArgument.filePath),
          numPoints = call.argument<Int>(MethodCallArgument.numPoints),
          onSuccess = { waveform -> result.success(waveform) },
          onError = { handleError(result, it) }
        )
      }

      else -> result.notImplemented()
    }
  }
}
