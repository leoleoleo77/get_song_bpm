#include <jni.h>
#include <android/log.h>
#include <BPMDetect.h>
#include <cstring>   // for memcpy

#define LOG_TAG "get_song_bpm"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

extern "C" JNIEXPORT jfloat JNICALL Java_com_leoleoleo_getsongbpm_JNIRepository_calculateBpm(
        JNIEnv *env,
        jobject /* this */,
        jobject pcmBuffer,
        jint bufferSize,
        jint sampleRate,
        jint channels
) {
    if (pcmBuffer == nullptr || bufferSize <= 0) {
        LOGE("Invalid PCM buffer or size");
        return -1.0f;
    }

    // Get pointer to PCM data
    int16_t *samples = reinterpret_cast<int16_t *>(env->GetDirectBufferAddress(pcmBuffer));
    if (!samples) {
        LOGE("Failed to get buffer address");
        return -1.0f;
    }

    size_t totalSamples = bufferSize / sizeof(int16_t);   // includes all channels
    size_t totalFrames  = totalSamples / channels;

    // Convert to float (interleaved preserved)
    std::vector<float> floatSamples(totalSamples);
    for (size_t i = 0; i < totalSamples; ++i) {
        floatSamples[i] = samples[i] / 32768.0f;
    }

    // Init BPM detector
    soundtouch::BPMDetect bpm(channels, sampleRate);

    // Feed in chunks of frames
    const size_t chunkFrames = sampleRate / 2; // half a second worth
    for (size_t f = 0; f < totalFrames; f += chunkFrames) {
        size_t remainingFrames = totalFrames - f;
        size_t currentFrames   = remainingFrames > chunkFrames ? chunkFrames : remainingFrames;
        bpm.inputSamples(&floatSamples[f * channels], currentFrames);
    }

    float bpmVal = bpm.getBpm();
    LOGI("Detected BPM: %f", bpmVal);

    return bpmVal;
}
