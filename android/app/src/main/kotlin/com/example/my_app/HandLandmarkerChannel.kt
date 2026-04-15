package com.example.my_app

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.example.my_app.camera.SilentVoiceCameraController
import com.example.my_app.recognition.MockRecognitionEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.example.my_app.recognition.DetectorType
import kotlin.math.max

class HandLandmarkerChannel(
    private val context: Context,
    private val cameraController: SilentVoiceCameraController,
) {

    companion object {
        const val METHOD_CHANNEL = "silent_voice/sign_recognition_method"
        const val EVENT_CHANNEL = "silent_voice/sign_recognition_events"
        const val LEGACY_METHOD_CHANNEL = "hand_landmarker/method"
        const val LEGACY_EVENT_CHANNEL = "hand_landmarker/events"
        private const val DEFAULT_INTERVAL_MS = 1200L
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private var eventSink: EventChannel.EventSink? = null
    private var activeDetectorType: DetectorType = DetectorType.HAND_LANDMARKER
    private var useMock: Boolean = true
    private var intervalMs: Long = DEFAULT_INTERVAL_MS
    private var isRecognizing: Boolean = false

    val methodHandler = MethodChannel.MethodCallHandler { call, result ->
        when (call.method) {
            "init" -> {
                try {
                    useMock = true
                    activeDetectorType = DetectorType.HAND_LANDMARKER
                    cameraController.configureRecognition(activeDetectorType, useMock)
                    result.success(statusPayload())
                } catch (error: IllegalStateException) {
                    result.error("INIT_FAILED", error.message, null)
                }
            }
            "initialize" -> {
                try {
                    applyArguments(call.arguments as? Map<*, *>)
                    cameraController.configureRecognition(activeDetectorType, useMock)
                    result.success(statusPayload())
                } catch (error: IllegalStateException) {
                    result.error("INIT_FAILED", error.message, null)
                }
            }
            "startRecognition" -> {
                try {
                    applyArguments(call.arguments as? Map<*, *>)
                    cameraController.configureRecognition(activeDetectorType, useMock)
                    startRecognition()
                    result.success(statusPayload())
                } catch (error: IllegalStateException) {
                    result.error("START_FAILED", error.message, null)
                }
            }
            "stopRecognition" -> {
                stopRecognition()
                result.success(statusPayload())
            }
            "detect" -> {
                try {
                    val payload = MockRecognitionEngine(activeDetectorType).detectMock().toMap()
                    eventSink?.success(payload)
                    result.success(payload)
                } catch (error: IllegalStateException) {
                    result.error("DETECT_FAILED", error.message, null)
                }
            }
            "getStatus" -> {
                result.success(statusPayload())
            }
            "dispose" -> {
                stopRecognition()
                cameraController.release()
                eventSink = null
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    val streamHandler = object : EventChannel.StreamHandler {
        override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
            eventSink = sink
            cameraController.setEventSink(sink)
        }

        override fun onCancel(arguments: Any?) {
            stopRecognition()
            cameraController.setEventSink(null)
            eventSink = null
        }
    }

    private val mockEmitter = object : Runnable {
        override fun run() {
            if (!isRecognizing) {
                return
            }

            val result = MockRecognitionEngine(activeDetectorType).detectMock()
            eventSink?.success(result.toMap())
            mainHandler.postDelayed(this, intervalMs)
        }
    }

    private fun applyArguments(arguments: Map<*, *>?) {
        if (arguments == null) {
            return
        }

        activeDetectorType = DetectorType.fromPlatformValue(arguments["detectorType"] as? String)
        useMock = arguments["useMock"] as? Boolean ?: useMock
        intervalMs = max((arguments["intervalMs"] as? Number)?.toLong() ?: intervalMs, 300L)
    }

    private fun startRecognition() {
        stopRecognition()
        isRecognizing = true
        cameraController.startRecognition()
        if (useMock) {
            mainHandler.post(mockEmitter)
        }
    }

    private fun stopRecognition() {
        isRecognizing = false
        mainHandler.removeCallbacks(mockEmitter)
        cameraController.stopRecognition()
    }

    private fun statusPayload(): Map<String, Any> {
        val cameraStatus = cameraController.statusPayload()
        return mapOf(
            "detectorType" to activeDetectorType.platformValue,
            "useMock" to useMock,
            "isRecognizing" to isRecognizing,
            "modelAvailable" to (cameraStatus["modelAvailable"] ?: false),
            "previewAttached" to (cameraStatus["previewAttached"] ?: false),
        )
    }
}
