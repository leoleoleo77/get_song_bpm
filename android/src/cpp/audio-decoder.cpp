#include <jni.h>
#include <android/log.h>
#include <media/NdkMediaExtractor.h>
#include <media/NdkMediaCodec.h>

#include <cstring>
#include <vector>
#include <cstdint>
#include <limits>

#define LOG_TAG "get_song_bpm"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

extern "C" JNIEXPORT jobject JNICALL Java_com_leoleoleo_getsongbpm_JNIRepository_decodeM4AtoPCM(
        JNIEnv *env,
        jobject /* this */,
        jint jFd
) {
    int fd = static_cast<int>(jFd);

    AMediaExtractor *extractor = AMediaExtractor_new();
    if (AMediaExtractor_setDataSourceFd(extractor, fd, 0, std::numeric_limits<long long>::max()) != AMEDIA_OK) {
        LOGE("Failed to set data source from fd");
        AMediaExtractor_delete(extractor);
        return nullptr;
    }

    // Find audio track
    int numTracks = AMediaExtractor_getTrackCount(extractor);
    int audioTrack = -1;
    for (int i = 0; i < numTracks; i++) {
        AMediaFormat *format = AMediaExtractor_getTrackFormat(extractor, i);
        const char *mime;
        if (AMediaFormat_getString(format, AMEDIAFORMAT_KEY_MIME, &mime) &&
            strncmp(mime, "audio/", 6) == 0) {
            audioTrack = i;
            AMediaFormat_delete(format);
            break;
        }
        AMediaFormat_delete(format);
    }

    if (audioTrack < 0) {
        LOGE("No audio track found");
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

    // Decode into vector
    std::vector<uint8_t> pcmData;
    bool sawInputEOS = false;
    bool sawOutputEOS = false;

    while (!sawOutputEOS) {
        if (!sawInputEOS) {
            ssize_t inputIndex = AMediaCodec_dequeueInputBuffer(codec, 10000);
            if (inputIndex >= 0) {
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

    LOGI("Decoded %zu bytes PCM", pcmData.size());

    // Allocate native memory for direct buffer
    void *nativeBuf = malloc(pcmData.size());
    if (!nativeBuf) {
        LOGE("malloc failed");
        return nullptr;
    }
    memcpy(nativeBuf, pcmData.data(), pcmData.size());

    // Wrap it as a DirectByteBuffer
    jobject directBuffer = env->NewDirectByteBuffer(nativeBuf, pcmData.size());
    if (directBuffer == nullptr) {
        LOGE("Failed to create DirectByteBuffer");
        free(nativeBuf);
        return nullptr;
    }

    return directBuffer;
}

extern "C" JNIEXPORT void JNICALL Java_com_leoleoleo_getsongbpm_JNIRepository_releaseBuffer(
        JNIEnv *env,
jobject /* this */,
jobject buffer
) {

if (buffer == nullptr) return;

void *addr = env->GetDirectBufferAddress(buffer);
if (addr != nullptr) {
free(addr);
LOGI("Freed native buffer at %p", addr);
} else {
LOGE("freeBuffer: buffer address was null!");
}
}