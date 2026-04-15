package com.example.my_app.recognition

data class RecognitionLandmark(
    val x: Float,
    val y: Float,
    val z: Float,
)

data class RecognitionHandPayload(
    val handedness: String,
    val confidence: Float,
    val landmarks: List<RecognitionLandmark>,
) {
    fun toMap(): Map<String, Any> {
        return mapOf(
            "handedness" to handedness,
            "confidence" to confidence.toDouble(),
            "landmarks" to landmarks.map { landmark ->
                mapOf(
                    "x" to landmark.x.toDouble(),
                    "y" to landmark.y.toDouble(),
                    "z" to landmark.z.toDouble(),
                )
            },
        )
    }
}

data class RecognitionResultPayload(
    val recognizedLabel: String,
    val confidence: Float,
    val handedness: String,
    val landmarks: List<RecognitionLandmark>,
    val hands: List<RecognitionHandPayload> = emptyList(),
    val timestamp: Long,
    val detectorType: String,
    val isMock: Boolean,
    val frameWidth: Int,
    val frameHeight: Int,
    val isFrontCamera: Boolean,
) {
    fun toMap(): Map<String, Any> {
        return mapOf(
            "recognizedLabel" to recognizedLabel,
            "confidence" to confidence.toDouble(),
            "handedness" to handedness,
            "landmarks" to landmarks.map { landmark ->
                mapOf(
                    "x" to landmark.x.toDouble(),
                    "y" to landmark.y.toDouble(),
                    "z" to landmark.z.toDouble(),
                )
            },
            "hands" to hands.map { hand -> hand.toMap() },
            "timestamp" to timestamp,
            "detectorType" to detectorType,
            "isMock" to isMock,
            "frameWidth" to frameWidth,
            "frameHeight" to frameHeight,
            "isFrontCamera" to isFrontCamera,
        )
    }
}

enum class DetectorType(val platformValue: String, val modelAssetName: String?) {
    HAND_LANDMARKER("handLandmarker", "assets/models/hand_landmarker.task"),
    GESTURE_RECOGNIZER("gestureRecognizer", "assets/models/gesture_recognizer.task");

    companion object {
        fun fromPlatformValue(value: String?): DetectorType {
            return entries.firstOrNull { it.platformValue == value } ?: HAND_LANDMARKER
        }
    }
}
