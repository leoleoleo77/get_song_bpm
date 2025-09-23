#include <jni.h>
#include <android/log.h>
#include <vector>
#include <cstdint>
#include <cmath>
#include <algorithm>  // for std::min

#define LOG_TAG "get_song_waveform"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

extern "C" JNIEXPORT jfloatArray JNICALL
Java_com_leoleoleo_getsongbpm_JNIRepository_extractWaveform(
        JNIEnv *env,
        jobject /* this */,
        jobject pcmBuffer,
        jint bufferSize,
        jint sampleRate,
        jint channels,
        jint numPoints
) {
    if (pcmBuffer == nullptr || bufferSize <= 0 || numPoints <= 0) {
        LOGE("Invalid params for waveform extraction");
        return nullptr;
    }

    int16_t *samples = reinterpret_cast<int16_t *>(env->GetDirectBufferAddress(pcmBuffer));
    if (!samples) {
        LOGE("Failed to get PCM buffer address");
        return nullptr;
    }

    size_t totalSamples = bufferSize / sizeof(int16_t);
    size_t totalFrames  = totalSamples / channels;

    // How many frames each point represents
    size_t framesPerPoint = totalFrames / numPoints;
    if (framesPerPoint == 0) framesPerPoint = 1;

    std::vector<float> waveform(numPoints, 0.0f);

    for (int p = 0; p < numPoints; p++) {
        size_t startFrame = p * framesPerPoint;
        size_t endFrame   = std::min(totalFrames, startFrame + framesPerPoint);

        float peak = 0.0f;
        for (size_t f = startFrame; f < endFrame; f++) {
            for (int c = 0; c < channels; c++) {
                int16_t sample = samples[f * channels + c];
                float val = std::abs(sample / 32768.0f);
                if (val > peak) peak = val;
            }
        }
        waveform[p] = peak;
    }

    // Convert to Java float[]
    jfloatArray result = env->NewFloatArray(numPoints);
    if (!result) {
        LOGE("Failed to allocate jfloatArray");
        return nullptr;
    }
    env->SetFloatArrayRegion(result, 0, numPoints, waveform.data());

    return result;
}
