package com.example.my_app.camera

import android.content.Context
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.example.my_app.recognition.DetectorType
import com.example.my_app.recognition.RecognitionEngine
import com.example.my_app.recognition.RecognitionEngineFactory
import io.flutter.plugin.common.EventChannel
import android.os.Handler
import android.os.Looper
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

class SilentVoiceCameraController(
    private val context: Context,
) {
    private val engineFactory = RecognitionEngineFactory(context)
    private val analysisExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private val analysisInFlight = AtomicBoolean(false)
    private val mainHandler = Handler(Looper.getMainLooper())

    private var processCameraProvider: ProcessCameraProvider? = null
    private var previewView: PreviewView? = null
    private var lifecycleOwner: LifecycleOwner? = null
    private var recognitionEngine: RecognitionEngine? = null
    private var recognitionEnabled = false
    private var useMock = false
    private var detectorType: DetectorType = DetectorType.HAND_LANDMARKER
    private var eventSink: EventChannel.EventSink? = null

    fun setEventSink(sink: EventChannel.EventSink?) {
        eventSink = sink
    }

    fun configureRecognition(detectorType: DetectorType, useMock: Boolean) {
        val engineNeedsRefresh =
            recognitionEngine == null ||
                recognitionEngine?.detectorType != detectorType ||
                this.useMock != useMock

        this.detectorType = detectorType
        this.useMock = useMock

        if (engineNeedsRefresh) {
            recognitionEngine?.close()
            recognitionEngine = engineFactory.create(detectorType, useMock).also {
                it.initialize()
            }
        }
    }

    fun startRecognition() {
        recognitionEnabled = true
    }

    fun stopRecognition() {
        recognitionEnabled = false
        analysisInFlight.set(false)
    }

    fun attachPreviewView(previewView: PreviewView, lifecycleOwner: LifecycleOwner) {
        this.previewView = previewView
        this.lifecycleOwner = lifecycleOwner
        bindCamera()
    }

    fun detachPreviewView(previewView: PreviewView) {
        if (this.previewView !== previewView) {
            return
        }

        this.previewView = null
        this.lifecycleOwner = null
        processCameraProvider?.unbindAll()
    }

    fun release() {
        stopRecognition()
        processCameraProvider?.unbindAll()
        recognitionEngine?.close()
        recognitionEngine = null
        previewView = null
        lifecycleOwner = null
        eventSink = null
    }

    fun statusPayload(): Map<String, Any> {
        return mapOf(
            "detectorType" to detectorType.platformValue,
            "useMock" to useMock,
            "isRecognizing" to recognitionEnabled,
            "modelAvailable" to (recognitionEngine?.isModelAvailable() ?: false),
            "previewAttached" to (previewView != null),
        )
    }

    private fun bindCamera() {
        val previewView = previewView ?: return
        val lifecycleOwner = lifecycleOwner ?: return
        val future = ProcessCameraProvider.getInstance(context)

        future.addListener(
            {
                try {
                    val cameraProvider = future.get()
                    processCameraProvider = cameraProvider
                    cameraProvider.unbindAll()

                    val preview = Preview.Builder()
                        .build()
                        .also { it.surfaceProvider = previewView.surfaceProvider }

                val analysis = ImageAnalysis.Builder()
                    .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                    .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_RGBA_8888)
                    .build()
                    .also { useCase ->
                        useCase.setAnalyzer(analysisExecutor) { imageProxy ->
                            analyzeFrame(imageProxy)
                        }
                        }

                    previewView.scaleType = PreviewView.ScaleType.FILL_CENTER

                    cameraProvider.bindToLifecycle(
                        lifecycleOwner,
                        CameraSelector.DEFAULT_FRONT_CAMERA,
                        preview,
                        analysis,
                    )
                } catch (error: Exception) {
                    eventSink?.error("CAMERA_BIND_FAILED", error.message, null)
                }
            },
            ContextCompat.getMainExecutor(context),
        )
    }

    private fun analyzeFrame(imageProxy: androidx.camera.core.ImageProxy) {
        if (!recognitionEnabled) {
            imageProxy.close()
            return
        }

        val engine = recognitionEngine
        if (engine == null) {
            imageProxy.close()
            return
        }

        if (!analysisInFlight.compareAndSet(false, true)) {
            imageProxy.close()
            return
        }

        try {
            val payload = engine.analyze(imageProxy, true)
            if (payload != null) {
                mainHandler.post {
                    eventSink?.success(payload.toMap())
                }
            }
        } catch (error: Exception) {
            mainHandler.post {
                eventSink?.error("ANALYZE_FAILED", error.message, null)
            }
        } finally {
            imageProxy.close()
            analysisInFlight.set(false)
        }
    }
}
