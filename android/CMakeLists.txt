# We're required to set some minimum version here
cmake_minimum_required(VERSION 3.18.1)

# --- Add the SoundTouch library source as a subdirectory ---
# Assumes SoundTouch source is located in 'soundtouch/' relative to this CMakeLists.txt
add_subdirectory(src/cpp/soundtouch)

# --- Find and link standard Android NDK libraries ---
find_library(
        log-lib             # Variable to hold the library path
        log                 # The library to find (for logging)
)

# This helper variable points to the location of the native sources
set(NATIVE_SRC_DIR src/cpp)
# Add specific source files to the library

# --- Define our JNI bridge library ---
add_library(
        bpm_calculator_jni  # Library name
        SHARED              # Must be a shared library for JNI
        ${NATIVE_SRC_DIR}/jni-bridge.cpp      # The C++ file containing JNI functions
)

# --- Link our JNI bridge against SoundTouch and Android libraries ---
target_link_libraries(
        bpm_calculator_jni
        PRIVATE
        SoundTouch          # Link against the SoundTouch library target
        ${log-lib}          # Link against the Android log library
)
