#include <jni.h>
#include <android/log.h>
#include <BPMDetect.h>
#include <cstring>   // for memcpy
#include <vector>
#include <cstdarg>
#include <algorithm>
#include <cmath>

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

extern "C" JNIEXPORT jfloat JNICALL
Java_com_leoleoleo_getsongbpm_JNIRepository_calculateBpm(
        JNIEnv *env,
        jobject /* this */,
        jobject pcmBuffer,
        jint bufferSize,
        jint sampleRate,
        jint channels,
        jstring jLogTag
) {
    const char *logTag = env->GetStringUTFChars(jLogTag, nullptr);

    if (!pcmBuffer || bufferSize <= 0) {
        safeLogE(logTag, "[C++] Invalid PCM buffer or size");
        env->ReleaseStringUTFChars(jLogTag, logTag);
        return -1.0f;
    }

    int16_t *samples = reinterpret_cast<int16_t *>(env->GetDirectBufferAddress(pcmBuffer));
    if (!samples) {
        safeLogE(logTag, "[C++] Failed to get buffer address");
        env->ReleaseStringUTFChars(jLogTag, logTag);
        return -1.0f;
    }

    size_t totalSamples = bufferSize / sizeof(int16_t);
    size_t totalFrames  = totalSamples / channels;

    safeLogI(logTag, "[C++] PCM info -> totalSamples=%zu, totalFrames=%zu, channels=%d, sampleRate=%d",
             totalSamples, totalFrames, channels, sampleRate);

    // Log min/max amplitude
    int16_t minSample = samples[0];
    int16_t maxSample = samples[0];
    double sumAbs = 0.0;
    for (size_t i = 0; i < totalSamples; ++i) {
        if (samples[i] < minSample) minSample = samples[i];
        if (samples[i] > maxSample) maxSample = samples[i];
        sumAbs += std::abs(samples[i]);
    }
    double avgAbs = sumAbs / totalSamples;
    safeLogI(logTag, "[C++] Sample stats -> min=%d, max=%d, avgAbs=%.4f",
             minSample, maxSample, avgAbs / 32768.0);

    if (totalFrames < 2) {
        safeLogI(logTag, "[C++] Warning: very few frames (%zu), BPM detection may be unreliable", totalFrames);
    }

    // Convert to float
    std::vector<float> floatSamples(totalSamples);
    for (size_t i = 0; i < totalSamples; ++i) {
        floatSamples[i] = samples[i] / 32768.0f;
    }

    // Init BPM detector
    soundtouch::BPMDetect bpm(channels, sampleRate);

    // Feed in chunks
    const size_t chunkFrames = sampleRate / 2; // half-second
    size_t chunksProcessed = 0;
    for (size_t f = 0; f < totalFrames; f += chunkFrames) {
        size_t remainingFrames = totalFrames - f;
        size_t currentFrames   = remainingFrames > chunkFrames ? chunkFrames : remainingFrames;
        bpm.inputSamples(&floatSamples[f * channels], currentFrames);
        chunksProcessed++;
    }

    safeLogI(logTag, "[C++] Processed %zu chunks for BPM detection", chunksProcessed);

    float bpmVal = bpm.getBpm();
    safeLogI(logTag, "[C++] Detected BPM: %f", bpmVal);

    env->ReleaseStringUTFChars(jLogTag, logTag);
    return bpmVal;
}
