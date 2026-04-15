package com.example.my_app.recognition

import android.content.Context
import io.flutter.FlutterInjector
import java.io.IOException

abstract class MediaPipeRecognitionEngine(
    protected val context: Context,
    override val detectorType: DetectorType,
) : RecognitionEngine {
    protected fun localizeHandedness(rawValue: String?): String {
        return when (rawValue) {
            "Left" -> "左手"
            "Right" -> "右手"
            else -> "未知"
        }
    }

    protected fun resolveModelAssetPath(): String {
        val assetPath = detectorType.modelAssetName
            ?: throw IllegalStateException("No model configured for ${detectorType.platformValue}")
        return FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(assetPath)
    }

    protected fun assertModelExists() {
        val assetPath = resolveModelAssetPath()

        try {
            context.assets.open(assetPath).close()
        } catch (error: IOException) {
            throw IllegalStateException(
                "Model asset not found for ${detectorType.platformValue}: $assetPath",
                error,
            )
        }
    }

    override fun isModelAvailable(): Boolean {
        val assetPath = try {
            resolveModelAssetPath()
        } catch (_: IllegalStateException) {
            return false
        }
        return try {
            context.assets.open(assetPath).close()
            true
        } catch (_: IOException) {
            false
        }
    }
}
