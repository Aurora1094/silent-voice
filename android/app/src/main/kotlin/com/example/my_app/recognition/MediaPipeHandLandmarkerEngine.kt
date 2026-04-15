package com.example.my_app.recognition

import android.content.Context
import androidx.camera.core.ImageProxy
import com.google.mediapipe.framework.image.MediaImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.ImageProcessingOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.handlandmarker.HandLandmarker

class MediaPipeHandLandmarkerEngine(
    context: Context,
) : MediaPipeRecognitionEngine(context, DetectorType.HAND_LANDMARKER) {

    private var handLandmarker: HandLandmarker? = null

    override fun initialize() {
        if (handLandmarker != null) {
            return
        }

        assertModelExists()

        val baseOptions = BaseOptions.builder()
            .setModelAssetPath(resolveModelAssetPath())
            .build()

        val options = HandLandmarker.HandLandmarkerOptions.builder()
            .setBaseOptions(baseOptions)
            .setRunningMode(RunningMode.VIDEO)
            .setNumHands(2)
            .setMinHandDetectionConfidence(0.5f)
            .setMinHandPresenceConfidence(0.5f)
            .setMinTrackingConfidence(0.5f)
            .build()

        handLandmarker = HandLandmarker.createFromOptions(context, options)
    }

    override fun close() {
        handLandmarker?.close()
        handLandmarker = null
    }

    override fun detectMock(): RecognitionResultPayload {
        return MockRecognitionEngine(detectorType).detectMock().copy(
            recognizedLabel = "模拟手部结果",
            handedness = "未知",
        )
    }

    override fun analyze(
        imageProxy: ImageProxy,
        isFrontCamera: Boolean,
    ): RecognitionResultPayload? {
        val image = imageProxy.image ?: return null
        val landmarker = handLandmarker ?: return null
        val timestampMs = imageProxy.imageInfo.timestamp / 1_000_000L
        val mpImage = MediaImageBuilder(image).build()
        val imageProcessingOptions = ImageProcessingOptions.builder()
            .setRotationDegrees(imageProxy.imageInfo.rotationDegrees)
            .build()
        val result = landmarker.detectForVideo(mpImage, imageProcessingOptions, timestampMs)

        if (result.landmarks().isEmpty()) {
            return RecognitionResultPayload(
                recognizedLabel = "未检测到手部",
                confidence = 0.0f,
                handedness = "未知",
                landmarks = emptyList(),
                hands = emptyList(),
                timestamp = timestampMs,
                detectorType = detectorType.platformValue,
                isMock = false,
                frameWidth = imageProxy.height,
                frameHeight = imageProxy.width,
                isFrontCamera = isFrontCamera,
            )
        }

        val hands = result.landmarks().mapIndexed { index, handLandmarks ->
            val landmarks = handLandmarks.map { landmark ->
                RecognitionLandmark(
                    x = landmark.x(),
                    y = landmark.y(),
                    z = landmark.z(),
                )
            }

            val handednessCategory = result.handednesses()
                .getOrNull(index)
                ?.firstOrNull()

            RecognitionHandPayload(
                handedness = localizeHandedness(handednessCategory?.categoryName()),
                confidence = handednessCategory?.score() ?: 0.0f,
                landmarks = landmarks,
            )
        }

        val firstHand = hands.first()

        return RecognitionResultPayload(
            recognizedLabel = if (hands.size > 1) "检测到${hands.size}只手" else "检测到手部",
            confidence = firstHand.confidence,
            handedness = firstHand.handedness,
            landmarks = firstHand.landmarks,
            hands = hands,
            timestamp = timestampMs,
            detectorType = detectorType.platformValue,
            isMock = false,
            frameWidth = imageProxy.height,
            frameHeight = imageProxy.width,
            isFrontCamera = isFrontCamera,
        )
    }
}
