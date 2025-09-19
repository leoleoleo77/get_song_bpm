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

private object MethodCallName {

  val convertM4AInputFileToRawPCMByteArray
    get() = "convertM4AInputFileToRawPCMByteArray"

  val getBpmFromAudioFile
    get() = "getBpmFromAudioFile"
}

private object MethodCallArgument {
  val filePath
    get() = "filePath"
}

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
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {

      MethodCallName.convertM4AInputFileToRawPCMByteArray -> {
        MethodCallRepository.convertM4AInputFileToRawPCMByteArray(
          scope = scope,
          pathname = call.argument<String>(MethodCallArgument.filePath),
          onSuccess = { isSuccess -> result.success(isSuccess) },
          onError = { error -> result.error("ERROR", error.message, null) }
        )
      }

      MethodCallName.getBpmFromAudioFile ->  {
        MethodCallRepository.getBpmFromAudioFile(
          scope = scope,
          pathname = call.argument<String>(MethodCallArgument.filePath),
          onSuccess = { bpm -> result.success(bpm) },
          onError = { error -> result.error("ERROR", error.message, null) }
        )
      }

      else -> result.notImplemented()
    }
  }
}
