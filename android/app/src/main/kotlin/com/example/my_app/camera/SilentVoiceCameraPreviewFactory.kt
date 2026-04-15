package com.example.my_app.camera

import android.content.Context
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec

class SilentVoiceCameraPreviewFactory(
    private val messenger: BinaryMessenger,
    private val controller: SilentVoiceCameraController,
    private val lifecycleOwner: LifecycleOwner,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return SilentVoiceCameraPreviewView(context, controller, lifecycleOwner)
    }
}
