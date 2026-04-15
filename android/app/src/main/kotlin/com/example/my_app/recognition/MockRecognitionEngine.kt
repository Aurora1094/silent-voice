package com.example.my_app.recognition

import androidx.camera.core.ImageProxy
import kotlin.random.Random

class MockRecognitionEngine(
    override val detectorType: DetectorType,
) : RecognitionEngine {

    override fun initialize() = Unit

    override fun close() = Unit

    override fun detectMock(): RecognitionResultPayload {
        val random = Random(System.currentTimeMillis())
        val confidence = 0.72f + random.nextFloat() * 0.25f
        val handedness = if (random.nextBoolean()) "Right" else "Left"
        val label = when (detectorType) {
            DetectorType.GESTURE_RECOGNIZER -> listOf(
                "Open Palm",
                "Thumbs Up",
                "Closed Fist",
                "Pointing Up",
            ).random(random)
            DetectorType.HAND_LANDMARKER -> "Hand detected"
        }
        val landmarks = buildMockLandmarks(random)

        return RecognitionResultPayload(
            recognizedLabel = label,
            confidence = confidence,
            handedness = handedness,
            landmarks = landmarks,
            hands = listOf(
                RecognitionHandPayload(
                    handedness = handedness,
                    confidence = confidence,
                    landmarks = landmarks,
                )
            ),
            timestamp = System.currentTimeMillis(),
            detectorType = detectorType.platformValue,
            isMock = true,
            frameWidth = 720,
            frameHeight = 1280,
            isFrontCamera = true,
        )
    }

    override fun analyze(imageProxy: ImageProxy, isFrontCamera: Boolean): RecognitionResultPayload {
        val mockResult = detectMock()
        return mockResult.copy(
            timestamp = System.currentTimeMillis(),
            frameWidth = imageProxy.height,
            frameHeight = imageProxy.width,
            isFrontCamera = isFrontCamera,
        )
    }

    override fun isModelAvailable(): Boolean = true

    private fun buildMockLandmarks(random: Random): List<RecognitionLandmark> {
        val basePoints = listOf(
            0.48f to 0.88f,
            0.42f to 0.74f,
            0.36f to 0.62f,
            0.33f to 0.50f,
            0.30f to 0.38f,
            0.47f to 0.68f,
            0.46f to 0.52f,
            0.45f to 0.37f,
            0.44f to 0.22f,
            0.56f to 0.66f,
            0.57f to 0.50f,
            0.58f to 0.35f,
            0.59f to 0.20f,
            0.65f to 0.69f,
            0.68f to 0.55f,
            0.71f to 0.42f,
            0.74f to 0.30f,
            0.72f to 0.79f,
            0.76f to 0.69f,
            0.80f to 0.60f,
            0.84f to 0.51f,
        )

        return basePoints.map { (x, y) ->
            RecognitionLandmark(
                x = (x + random.nextDouble(-0.015, 0.015).toFloat()).coerceIn(0f, 1f),
                y = (y + random.nextDouble(-0.015, 0.015).toFloat()).coerceIn(0f, 1f),
                z = random.nextDouble(-0.08, 0.08).toFloat(),
            )
        }
    }
}
