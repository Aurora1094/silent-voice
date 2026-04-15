package com.example.my_app.recognition

import android.content.Context

class RecognitionEngineFactory(
    private val context: Context,
) {
    fun create(detectorType: DetectorType, useMock: Boolean): RecognitionEngine {
        if (useMock) {
            return MockRecognitionEngine(detectorType)
        }

        return when (detectorType) {
            DetectorType.HAND_LANDMARKER -> MediaPipeHandLandmarkerEngine(context)
            DetectorType.GESTURE_RECOGNIZER -> MediaPipeGestureRecognizerEngine(context)
        }
    }
}
