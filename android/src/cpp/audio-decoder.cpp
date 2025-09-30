#include <jni.h>
#include <android/log.h>
#include <media/NdkMediaExtractor.h>
#include <media/NdkMediaCodec.h>

#include <cstring>
#include <vector>
#include <cstdint>
#include <limits>
#include <cstdarg>

// Safe logging helpers
inline void safeLogI(const char *logTag, const char *fmt, ...) {
    if (!logTag || logTag[0] == '\0') return;
    va_list args;
    va_start(args, fmt);
    __android_log_vprint(ANDROID_LOG_INFO, logTag, fmt, args);
    va_end(args);
}

inline void safeLogE(const char *logTag, const char *fmt, ...) {
    if (!logTag || logTag[0] == '\0') return;
    va_list args;
    va_start(args, fmt);
    __android_log_vprint(ANDROID_LOG_ERROR, logTag, fmt, args);
    va_end(args);
}

extern "C" JNIEXPORT jobject JNICALL
Java_com_leoleoleo_getsongbpm_JNIRepository_decodeM4AtoPCM(
        JNIEnv *env,
        jobject /* this */,
        jint jFd,
        jstring jLogTag
) {
    const char *logTag = env->GetStringUTFChars(jLogTag, nullptr);
    int fd = static_cast<int>(jFd);

    AMediaExtractor *extractor = AMediaExtractor_new();
    if (AMediaExtractor_setDataSourceFd(extractor, fd, 0, std::numeric_limits<long long>::max()) != AMEDIA_OK) {
        safeLogE(logTag, "[C++] Failed to set data source from fd");
        env->ReleaseStringUTFChars(jLogTag, logTag);
        AMediaExtractor_delete(extractor);
        return nullptr;
    }

    // Find audio track
    int numTracks = AMediaExtractor_getTrackCount(extractor);
    safeLogI(logTag, "[C++] Found %d track(s) in file", numTracks);

    int audioTrack = -1;
    for (int i = 0; i < numTracks; i++) {
        AMediaFormat *format = AMediaExtractor_getTrackFormat(extractor, i);
        const char *mime;
        if (AMediaFormat_getString(format, AMEDIAFORMAT_KEY_MIME, &mime) &&
            strncmp(mime, "audio/", 6) == 0) {
            audioTrack = i;
            safeLogI(logTag, "[C++] Selected audio track %d with MIME type: %s", i, mime);
            AMediaFormat_delete(format);
            break;
        }
        AMediaFormat_delete(format);
    }

    if (audioTrack < 0) {
        safeLogE(logTag, "[C++] No audio track found");
        env->ReleaseStringUTFChars(jLogTag, logTag);
        AMediaExtractor_delete(extractor);
        return nullptr;
    }

    AMediaExtractor_selectTrack(extractor, audioTrack);
    AMediaFormat *format = AMediaExtractor_getTrackFormat(extractor, audioTrack);
    const char *mime = nullptr;
    AMediaFormat_getString(format, AMEDIAFORMAT_KEY_MIME, &mime);

    AMediaCodec *codec = AMediaCodec_createDecoderByType(mime);
    AMediaCodec_configure(codec, format, nullptr, nullptr, 0);
    AMediaCodec_start(codec);

    std::vector<uint8_t> pcmData;
    bool sawInputEOS = false;
    bool sawOutputEOS = false;
    size_t inputBuffersProcessed = 0;
    size_t outputBuffersProcessed = 0;

    while (!sawOutputEOS) {
        if (!sawInputEOS) {
            ssize_t inputIndex = AMediaCodec_dequeueInputBuffer(codec, 10000);
            if (inputIndex >= 0) {
                inputBuffersProcessed++;
                size_t bufSize;
                uint8_t *buf = AMediaCodec_getInputBuffer(codec, inputIndex, &bufSize);
                ssize_t sampleSize = AMediaExtractor_readSampleData(extractor, buf, bufSize);
                if (sampleSize < 0) {
                    AMediaCodec_queueInputBuffer(codec, inputIndex, 0, 0, 0,
                                                 AMEDIACODEC_BUFFER_FLAG_END_OF_STREAM);
                    sawInputEOS = true;
                } else {
                    int64_t pts = AMediaExtractor_getSampleTime(extractor);
                    AMediaCodec_queueInputBuffer(codec, inputIndex, 0, sampleSize, pts, 0);
                    AMediaExtractor_advance(extractor);
                }
            }
        }

        AMediaCodecBufferInfo info;
        ssize_t outputIndex = AMediaCodec_dequeueOutputBuffer(codec, &info, 10000);
        if (outputIndex >= 0) {
            outputBuffersProcessed++;
            size_t outSize;
            uint8_t *outBuf = AMediaCodec_getOutputBuffer(codec, outputIndex, &outSize);
            if (info.size > 0 && outBuf != nullptr) {
                pcmData.insert(pcmData.end(), outBuf + info.offset, outBuf + info.offset + info.size);
            }
            AMediaCodec_releaseOutputBuffer(codec, outputIndex, false);

            if (info.flags & AMEDIACODEC_BUFFER_FLAG_END_OF_STREAM) {
                sawOutputEOS = true;
            }
        }
    }

    AMediaCodec_stop(codec);
    AMediaCodec_delete(codec);
    AMediaFormat_delete(format);
    AMediaExtractor_delete(extractor);

    safeLogI(logTag, "[C++] Decoded %zu bytes PCM using %zu input and %zu output buffers",
             pcmData.size(), inputBuffersProcessed, outputBuffersProcessed);

    if (pcmData.empty()) {
        safeLogI(logTag, "[C++] Warning: PCM buffer is empty after decoding");
    }

    // Allocate native memory for DirectByteBuffer
    void *nativeBuf = malloc(pcmData.size());
    if (!nativeBuf) {
        safeLogE(logTag, "[C++] malloc failed");
        env->ReleaseStringUTFChars(jLogTag, logTag);
        return nullptr;
    }
    memcpy(nativeBuf, pcmData.data(), pcmData.size());

    jobject directBuffer = env->NewDirectByteBuffer(nativeBuf, pcmData.size());
    if (!directBuffer) {
        safeLogE(logTag, "[C++] Failed to create DirectByteBuffer");
        free(nativeBuf);
        env->ReleaseStringUTFChars(jLogTag, logTag);
        return nullptr;
    }

    safeLogI(logTag, "[C++] decodeM4AtoPCM complete, buffer size: %zu bytes", pcmData.size());
    env->ReleaseStringUTFChars(jLogTag, logTag);
    return directBuffer;
}

extern "C" JNIEXPORT void JNICALL
Java_com_leoleoleo_getsongbpm_JNIRepository_releaseBuffer(
        JNIEnv *env,
        jobject /* this */,
        jobject buffer,
        jstring jLogTag
) {
    if (!buffer) return;

    const char *logTag = env->GetStringUTFChars(jLogTag, nullptr);
    void *addr = env->GetDirectBufferAddress(buffer);
    if (addr) {
    free(addr);
    safeLogI(logTag, "[C++] Freed native buffer at %p", addr);
    } else {
    safeLogE(logTag, "[C++] freeBuffer: buffer address was null!");
    }
    env->ReleaseStringUTFChars(jLogTag, logTag);
}
