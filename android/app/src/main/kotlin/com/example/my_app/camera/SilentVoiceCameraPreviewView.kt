package com.example.my_app.camera

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import androidx.camera.view.PreviewView
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.platform.PlatformView

class SilentVoiceCameraPreviewView(
    context: Context,
    private val controller: SilentVoiceCameraController,
    lifecycleOwner: LifecycleOwner,
) : PlatformView {
    private val previewView = PreviewView(context).apply {
        layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT,
        )
        implementationMode = PreviewView.ImplementationMode.COMPATIBLE
        scaleType = PreviewView.ScaleType.FILL_CENTER
    }

    init {
        controller.attachPreviewView(previewView, lifecycleOwner)
    }

    override fun getView(): View = previewView

    override fun dispose() {
        controller.detachPreviewView(previewView)
    }
}
