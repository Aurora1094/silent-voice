package com.example.my_app

import com.example.my_app.camera.SilentVoiceCameraController
import com.example.my_app.camera.SilentVoiceCameraPreviewFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val cameraController = SilentVoiceCameraController(this)
        val helper = HandLandmarkerChannel(this, cameraController)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HandLandmarkerChannel.METHOD_CHANNEL)
            .setMethodCallHandler(helper.methodHandler)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HandLandmarkerChannel.LEGACY_METHOD_CHANNEL)
            .setMethodCallHandler(helper.methodHandler)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, HandLandmarkerChannel.EVENT_CHANNEL)
            .setStreamHandler(helper.streamHandler)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, HandLandmarkerChannel.LEGACY_EVENT_CHANNEL)
            .setStreamHandler(helper.streamHandler)
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "silent_voice/native_camera_preview",
                SilentVoiceCameraPreviewFactory(
                    flutterEngine.dartExecutor.binaryMessenger,
                    cameraController,
                    this,
                ),
            )
    }
}
