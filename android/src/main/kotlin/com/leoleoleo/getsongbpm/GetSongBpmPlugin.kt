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

  private object MethodCallName {
    val getBpmFromAudioFile
      get() = "getBpmFromAudioFile"
  }

  private object MethodCallArgument {
    val filePath
      get() = "filePath"
  }

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

//  @TargetApi(Build.VERSION_CODES.HONEYCOMB_MR1)
//  private fun handleOnGetBpmFromAudioFile(call: MethodCall, result: Result) {
//    val parent = context.getExternalFilesDir(null)
//    println("parent: $parent.")
//    val file = File(parent, "LOOP_3.m4a")
//    val pfd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)
//    val fd = pfd.fd
//
//    val pcmData: ByteArray? = AudioDecoder.decodeM4AtoPCM(fd) // Capture the ByteArray?
//    pfd.close()
//
//    // ✅ Perform the check
//    if (pcmData == null || pcmData.isEmpty()) {
//      println("Decoding failed or produced no data.")
//      result.error("DECODING_ERROR", "Failed to decode audio to PCM.", null)
//    } else {
//      println("Successfully received ${pcmData.size} bytes of PCM data from JNI.")
//      // You can now proceed to save the file or process it
//      // Save the raw PCM data to a file for verification
//      try {
//        val outputFile = File(context.cacheDir, "decoded_output.raw")
//        outputFile.writeBytes(pcmData)
//        println("Saved raw PCM to: ${outputFile.absolutePath}")
//      } catch (e: Exception) {
//        println("Error saving PCM file: ${e.message}")
//      }
//
//      result.success(2.0) // Mocked BPM value for now
//    }
//  }
}
