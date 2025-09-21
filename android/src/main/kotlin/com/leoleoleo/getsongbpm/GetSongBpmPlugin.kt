package com.leoleoleo.getsongbpm

// Flutter imports
import com.leoleoleo.getsongbpm.utils.DebugLog
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

// Coroutine imports
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.cancel
import java.nio.ByteBuffer

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

  val sampleRate
    get() = "sampleRate"

  val channels
    get() = "channels"

  val isVerbose
    get() = "isVerbose"
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
    SongProfilerSingleton.clear()
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {

      MethodCallName.convertM4AInputFileToRawPCMByteArray -> {
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

      else -> result.notImplemented()
    }
  }

  private fun handleOnConversionSuccess(
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
      sampleRate = sampleRate,
      channels = channels
    )
    result.success(true)

    val isVerbose = true//call.argument<Boolean>(MethodCallArgument.isVerbose) == true
    if (isVerbose) {
      buildString {
        appendLine(DebugLog.getString("Song Profiler Data:"))
        appendLine(DebugLog.getString("  File Path   : $pathname"))
        appendLine(DebugLog.getString("  Pointer to PCM Data : $pointer"))
        appendLine(DebugLog.getString("  Sample Rate : $sampleRate Hz"))
        appendLine(DebugLog.getString("  Channels    : $channels"))
      }.also { print(it) }
    }
  }

  private fun handleError(result: Result, error: Exception) {
    result.error("ERROR", error.message, null)
  }
}
