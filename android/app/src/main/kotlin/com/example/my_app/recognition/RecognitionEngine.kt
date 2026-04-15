package com.example.my_app.recognition

import androidx.camera.core.ImageProxy

interface RecognitionEngine {
    val detectorType: DetectorType

    fun initialize()

    fun close()

    fun detectMock(): RecognitionResultPayload

    fun analyze(imageProxy: ImageProxy, isFrontCamera: Boolean): RecognitionResultPayload?

    fun isModelAvailable(): Boolean
}
