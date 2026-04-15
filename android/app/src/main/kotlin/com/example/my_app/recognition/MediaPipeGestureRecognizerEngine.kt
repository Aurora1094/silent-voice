package com.example.my_app.recognition

import android.content.Context
import androidx.camera.core.ImageProxy
import com.google.mediapipe.framework.image.MediaImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.ImageProcessingOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.gesturerecognizer.GestureRecognizer

class MediaPipeGestureRecognizerEngine(
    context: Context,
) : MediaPipeRecognitionEngine(context, DetectorType.GESTURE_RECOGNIZER) {

    private var gestureRecognizer: GestureRecognizer? = null

    override fun initialize() {
        if (gestureRecognizer != null) {
            return
        }

        assertModelExists()

        val baseOptions = BaseOptions.builder()
            .setModelAssetPath(resolveModelAssetPath())
            .build()

        val options = GestureRecognizer.GestureRecognizerOptions.builder()
            .setBaseOptions(baseOptions)
            .setRunningMode(RunningMode.VIDEO)
            .build()

        gestureRecognizer = GestureRecognizer.createFromOptions(context, options)
    }

    override fun close() {
        gestureRecognizer?.close()
        gestureRecognizer = null
    }

    override fun detectMock(): RecognitionResultPayload {
        return MockRecognitionEngine(detectorType).detectMock().copy(
            recognizedLabel = "模拟手势结果",
            handedness = "未知",
        )
    }

    override fun analyze(
        imageProxy: ImageProxy,
        isFrontCamera: Boolean,
    ): RecognitionResultPayload? {
        val image = imageProxy.image ?: return null
        val recognizer = gestureRecognizer ?: return null
        val timestampMs = imageProxy.imageInfo.timestamp / 1_000_000L
        val mpImage = MediaImageBuilder(image).build()
        val imageProcessingOptions = ImageProcessingOptions.builder()
            .setRotationDegrees(imageProxy.imageInfo.rotationDegrees)
            .build()
        val result = recognizer.recognizeForVideo(mpImage, imageProcessingOptions, timestampMs)

        if (result.gestures().isEmpty()) {
            return RecognitionResultPayload(
                recognizedLabel = "未检测到手势",
                confidence = 0.0f,
                handedness = "未知",
                landmarks = emptyList(),
                timestamp = timestampMs,
                detectorType = detectorType.platformValue,
                isMock = false,
                frameWidth = imageProxy.height,
                frameHeight = imageProxy.width,
                isFrontCamera = isFrontCamera,
            )
        }

        val topGesture = result.gestures().firstOrNull()?.firstOrNull()
        val handednessCategory = result.handedness().firstOrNull()?.firstOrNull()
        val landmarks = result.landmarks().firstOrNull()?.map { landmark ->
            RecognitionLandmark(
                x = landmark.x(),
                y = landmark.y(),
                z = landmark.z(),
            )
        } ?: emptyList()

        return RecognitionResultPayload(
            recognizedLabel = topGesture?.categoryName() ?: "检测到手势",
            confidence = topGesture?.score() ?: 0.0f,
            handedness = localizeHandedness(handednessCategory?.categoryName()),
            landmarks = landmarks,
            timestamp = timestampMs,
            detectorType = detectorType.platformValue,
            isMock = false,
            frameWidth = imageProxy.height,
            frameHeight = imageProxy.width,
            isFrontCamera = isFrontCamera,
        )
    }
}
