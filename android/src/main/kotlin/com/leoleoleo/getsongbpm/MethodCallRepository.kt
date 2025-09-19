package com.leoleoleo.getsongbpm

import android.os.Build
import android.os.ParcelFileDescriptor
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileNotFoundException

object MethodCallRepository {

    private suspend fun convertM4AInputFileToRawPCMByteArray(pathname: String?): ByteArray {
        return withContext(Dispatchers.IO) {

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

            // '.use' ensures the ParcelFileDescriptor is closed automatically
            val pcmData = pfd.use {
                val fd = it.fd

                JNIInterface.decodeM4AtoPCM(fd)
            }

            pcmData ?: throw RuntimeException("Failed to decode audio file. Result was null.")
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
                val pcmData = convertM4AInputFileToRawPCMByteArray(pathname)

                // Mocked BPM calculation, now safely on the main thread
                val bpm = pcmData.size.toDouble()
                onSuccess(bpm)
            } catch (e: Exception) {
                onError(e)
            }
        }
    }
}

