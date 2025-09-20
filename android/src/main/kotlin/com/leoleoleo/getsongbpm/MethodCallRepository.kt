package com.leoleoleo.getsongbpm

import android.os.Build
import android.os.ParcelFileDescriptor
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import java.io.File
import java.io.FileNotFoundException
import kotlinx.coroutines.withContext
import kotlinx.coroutines.Dispatchers

object MethodCallRepository {

    fun convertM4AInputFileToRawPCMByteArray(
        scope: CoroutineScope,
        pathname: String?,
        onSuccess: (Boolean) -> Unit,
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

                    val pcmData = pfd.use { JNIRepository.decodeM4AtoPCM(it.fd) }

                    if (pcmData != null) {
                        SongProfilerSingleton.newInstance(
                            filePath = pathname,
                            pcmData = pcmData
                        )
                        onSuccess(true)
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
                var bpm: Double?
                withContext(Dispatchers.IO) {
                    if (pathname.isNullOrEmpty()) {
                        throw IllegalArgumentException("File path cannot be null or empty")
                    }

                    val data = SongProfilerSingleton.getPCMDataFor(filePath = pathname)

                    bpm = data?.size?.toDouble()
                }
                onSuccess(bpm ?: -2.0)
            } catch (e: Exception) {
                onError(e)
            }
        }
    }
}

