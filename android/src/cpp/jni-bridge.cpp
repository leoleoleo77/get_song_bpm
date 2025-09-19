#include <jni.h>
#include <android/log.h>
#include <BPMDetect.h>
#include <cstring>   // for memcpy

extern "C" JNIEXPORT jfloat JNICALL
Java_com_leoleoleo_getsongbpm_JNIInterface_calculateBpm(
        JNIEnv *env,
        jobject /* this */,
        jobject audioBuffer,
        jint sampleRate,
        jint channels
) {
    // 1. Get the buffer pointer from Java's ByteBuffer
    void *bufferPtr = env->GetDirectBufferAddress(audioBuffer);
    if (bufferPtr == nullptr) {
        __android_log_print(ANDROID_LOG_ERROR, "BPM", "Buffer pointer is null");
        return -1.0f;
    }

    jlong bufferSize = env->GetDirectBufferCapacity(audioBuffer);
    if (bufferSize <= 0) {
        __android_log_print(ANDROID_LOG_ERROR, "BPM", "Buffer size is invalid");
        return -1.0f;
    }

    // 2. Create BPMDetect instance
    soundtouch::BPMDetect bpm(channels, sampleRate);

    // 3. Assume the data is 16-bit PCM
    int16_t *samples = static_cast<int16_t*>(bufferPtr);
    size_t numSamples = bufferSize / sizeof(int16_t);

    // 4. Convert to floats (SoundTouch expects floats)
    std::vector<float> floatSamples(numSamples);
    for (size_t i = 0; i < numSamples; ++i) {
        floatSamples[i] = samples[i] / 32768.0f;
    }

    // 5. Feed chunks to BPMDetect
    const size_t chunkSize = 1024;
    for (size_t i = 0; i < numSamples; i += chunkSize) {
        size_t remaining = numSamples - i;
        size_t currentChunk = remaining > chunkSize ? chunkSize : remaining;
        bpm.inputSamples(&floatSamples[i], currentChunk);
    }

    // 6. Get BPM result
    float bpmResult = bpm.getBpm();
    __android_log_print(ANDROID_LOG_INFO, "BPM", "Detected BPM: %.2f", bpmResult);

    return bpmResult;
}