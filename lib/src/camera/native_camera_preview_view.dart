import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NativeCameraPreviewView extends StatelessWidget {
  const NativeCameraPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Text(
            '当前设备暂不支持原生相机预览',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return const AndroidView(
      viewType: 'silent_voice/native_camera_preview',
      layoutDirection: TextDirection.ltr,
    );
  }
}
