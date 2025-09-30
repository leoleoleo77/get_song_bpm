#include <jni.h>
#include <android/log.h>
#include <cstdarg>
#include <vector>
#include <cstdint>
#include <cstdlib>
#include <cmath>
#include <algorithm>

inline void safeLog(int priority, const char *logTag, const char *fmt, ...) {
    if (logTag == nullptr || strlen(logTag) == 0) return;

    va_list args;
    va_start(args, fmt);
    __android_log_vprint(priority, logTag, fmt, args);
    va_end(args);
}

#define SAFE_LOGI(tag, fmt, ...) safeLog(ANDROID_LOG_INFO,  tag, fmt, ##__VA_ARGS__)
#define SAFE_LOGE(tag, fmt, ...) safeLog(ANDROID_LOG_ERROR, tag, fmt, ##__VA_ARGS__)

extern "C" JNIEXPORT jfloatArray JNICALL
Java_com_leoleoleo_getsongbpm_JNIRepository_extractWaveform(
        JNIEnv *env,
        jobject /* this */,
        jobject pcmBuffer,
        jint bufferSize,
        jint sampleRate,
        jint channels,
        jint numPoints,
        jstring jLogTag
) {
    const char *logTag = env->GetStringUTFChars(jLogTag, nullptr);

    SAFE_LOGI(logTag, "[C++] extractWaveform called");
    SAFE_LOGI(logTag, "[C++] Params -> bufferSize=%d, sampleRate=%d, channels=%d, numPoints=%d",
              bufferSize, sampleRate, channels, numPoints);

    if (pcmBuffer == nullptr || bufferSize <= 0 || numPoints <= 0) {
        SAFE_LOGE(logTag, "[C++] Invalid params for waveform extraction");
        env->ReleaseStringUTFChars(jLogTag, logTag);
        return nullptr;
    }

    int16_t *samples = reinterpret_cast<int16_t *>(env->GetDirectBufferAddress(pcmBuffer));
    if (!samples) {
        SAFE_LOGE(logTag, "[C++] Failed to get PCM buffer address");
        env->ReleaseStringUTFChars(jLogTag, logTag);
        return nullptr;
    }

    size_t totalSamples = bufferSize / sizeof(int16_t);
    size_t totalFrames  = totalSamples / channels;
    size_t framesPerPoint = totalFrames / numPoints;
    if (framesPerPoint == 0) framesPerPoint = 1;

    SAFE_LOGI(logTag, "[C++] totalSamples=%zu, totalFrames=%zu, framesPerPoint=%zu",
              totalSamples, totalFrames, framesPerPoint);

    // Log min/max sample values in the buffer
    int16_t minSample = samples[0];
    int16_t maxSample = samples[0];
    for (size_t i = 1; i < totalSamples; ++i) {
        if (samples[i] < minSample) minSample = samples[i];
        if (samples[i] > maxSample) maxSample = samples[i];
    }
    SAFE_LOGI(logTag, "[C++] Sample range -> min=%d, max=%d", minSample, maxSample);

    // Warn if the buffer is unusually small for waveform extraction
    if (totalFrames < numPoints) {
        SAFE_LOGI(logTag, "[C++] Warning: totalFrames (%zu) < numPoints (%d), points may repeat",
                  totalFrames, numPoints);
    }

    std::vector<float> waveform(numPoints, 0.0f);

    for (int p = 0; p < numPoints; p++) {
        size_t startFrame = p * framesPerPoint;
        size_t endFrame   = std::min(totalFrames, startFrame + framesPerPoint);

        float peak = 0.0f;
        float sumPeak = 0.0f;
        for (size_t f = startFrame; f < endFrame; f++) {
            for (int c = 0; c < channels; c++) {
                int16_t sample = samples[f * channels + c];
                float val = std::abs(sample / 32768.0f);
                sumPeak += val;
                if (val > peak) peak = val;
            }
        }
        waveform[p] = peak;
    }

    jfloatArray result = env->NewFloatArray(numPoints);
    if (!result) {
        SAFE_LOGE(logTag, "[C++] Failed to allocate jfloatArray");
        env->ReleaseStringUTFChars(jLogTag, logTag);
        return nullptr;
    }

    env->SetFloatArrayRegion(result, 0, numPoints, waveform.data());

    SAFE_LOGI(logTag, "[C++] Waveform extraction complete, generated %d points", numPoints);

    env->ReleaseStringUTFChars(jLogTag, logTag);
    return result;
}
