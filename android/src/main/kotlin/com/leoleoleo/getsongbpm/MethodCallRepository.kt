package com.leoleoleo.getsongbpm

import android.os.Build
import android.os.ParcelFileDescriptor
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import java.io.File
import java.io.FileNotFoundException
import kotlinx.coroutines.withContext
import kotlinx.coroutines.Dispatchers
import java.nio.ByteBuffer

object MethodCallRepository {

    fun convertM4AInputFileToRawPCMByteArray(
        scope: CoroutineScope,
        pathname: String?,
        onSuccess: (ByteBuffer, String) -> Unit,
        onError: (Exception) -> Unit,
    ) {
        scope.launch {
            try {
                withContext(Dispatchers.IO) {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN) {
                        throw UnsupportedOperationException("This method requires API level 16")
                    }

                    if (pathname.isNullOrEmpty()) {
                        throw IllegalArgumentException("File path cannot be null or empty")
                    }

                    val file = File(pathname)
                    if (!file.exists()) {
                        throw FileNotFoundException("File not found at path: $pathname")
                    }

                    val pfd = ParcelFileDescriptor.open(file, ParcelFileDescriptor.MODE_READ_ONLY)

                    val result = pfd.use { JNIRepository.decodeM4AtoPCM(it.fd) }
                    if (result != null) {
                        onSuccess(result, pathname)
                    } else {
                        throw RuntimeException("Failed to decode audio file. Result was null.")
                    }
                }
            } catch (e: Exception) {
                onError(e)
            }
        }
    }

    fun getBpmFromAudioFile(
        scope: CoroutineScope,
        pathname: String?,
        onSuccess: (Double) -> Unit,
        onError: (Exception) -> Unit,
    ) {
        scope.launch {
            try {
                withContext(Dispatchers.IO) {
                    if (pathname.isNullOrEmpty()) {
                        throw IllegalArgumentException("File path cannot be null or empty")
                    }

                    val data = SongProfilerSingleton.getPointerToPCMDataFor(filePath = pathname)

                    val result = if (data != null) {
                        JNIRepository.calculateBpm(
                            audioBuffer = data,
                            sampleRate = 44100,
                            channels = 1
                        ).toDouble()
                    } else {
                        throw IllegalStateException("PCM data not found for the given file path. Ensure that convertM4AInputFileToRawPCMByteArray is called first.")
                    }

                    onSuccess(result)
                }
            } catch (e: Exception) {
                onError(e)
            }
        }
    }
}

