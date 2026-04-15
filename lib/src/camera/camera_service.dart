import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

enum CameraStartStatus {
  ready,
  permissionDenied,
  permissionPermanentlyDenied,
  unavailable,
  error,
}

class CameraStartResult {
  const CameraStartResult._({
    required this.status,
    required this.message,
    this.controller,
  });

  const CameraStartResult.ready(CameraController controller)
      : this._(
          status: CameraStartStatus.ready,
          message: '摄像头预览已就绪。',
          controller: controller,
        );

  const CameraStartResult.accessReady(String message)
      : this._(
          status: CameraStartStatus.ready,
          message: message,
        );

  const CameraStartResult.failure(CameraStartStatus status, String message)
      : this._(status: status, message: message);

  final CameraStartStatus status;
  final String message;
  final CameraController? controller;

  bool get isReady => status == CameraStartStatus.ready;
}

class CameraService {
  CameraController? _controller;
  bool _isInitializing = false;

  CameraController? get controller => _controller;

  Future<CameraStartResult> ensureCameraAccess({
    CameraLensDirection preferredLensDirection = CameraLensDirection.front,
  }) async {
    if (_isInitializing) {
      return const CameraStartResult.failure(
        CameraStartStatus.error,
        '摄像头正在初始化，请稍后重试。',
      );
    }

    _isInitializing = true;
    try {
      var permissionStatus = await Permission.camera.status;
      if (!permissionStatus.isGranted) {
        permissionStatus = await Permission.camera.request();
      }

      if (permissionStatus.isPermanentlyDenied) {
        return const CameraStartResult.failure(
          CameraStartStatus.permissionPermanentlyDenied,
          '摄像头权限被永久拒绝，请到系统设置中开启。',
        );
      }

      if (!permissionStatus.isGranted) {
        return const CameraStartResult.failure(
          CameraStartStatus.permissionDenied,
          '摄像头权限被拒绝。',
        );
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return const CameraStartResult.failure(
          CameraStartStatus.unavailable,
          '当前设备没有可用摄像头。',
        );
      }

      _pickCamera(
        cameras,
        preferredLensDirection: preferredLensDirection,
      );

      return const CameraStartResult.accessReady('摄像头权限和设备检查通过。');
    } on CameraException catch (error) {
      return CameraStartResult.failure(
        CameraStartStatus.error,
        '摄像头异常：${error.description ?? error.code}',
      );
    } catch (error) {
      return CameraStartResult.failure(
        CameraStartStatus.error,
        '摄像头发生未知异常：$error',
      );
    } finally {
      _isInitializing = false;
    }
  }

  Future<CameraStartResult> initializePreview({
    CameraLensDirection preferredLensDirection = CameraLensDirection.front,
  }) async {
    if (_isInitializing) {
      return const CameraStartResult.failure(
        CameraStartStatus.error,
        '摄像头正在初始化，请稍后重试。',
      );
    }

    _isInitializing = true;
    try {
      var permissionStatus = await Permission.camera.status;
      if (!permissionStatus.isGranted) {
        permissionStatus = await Permission.camera.request();
      }

      if (permissionStatus.isPermanentlyDenied) {
        return const CameraStartResult.failure(
          CameraStartStatus.permissionPermanentlyDenied,
          '摄像头权限被永久拒绝，请到系统设置中开启。',
        );
      }

      if (!permissionStatus.isGranted) {
        return const CameraStartResult.failure(
          CameraStartStatus.permissionDenied,
          '摄像头权限被拒绝。',
        );
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return const CameraStartResult.failure(
          CameraStartStatus.unavailable,
          '当前设备没有可用摄像头。',
        );
      }

      final selectedCamera = _pickCamera(
        cameras,
        preferredLensDirection: preferredLensDirection,
      );

      await release();

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      try {
        await controller.initialize();
      } on CameraException catch (error) {
        await controller.dispose();
        return CameraStartResult.failure(
          CameraStartStatus.error,
          '摄像头初始化失败：${error.description ?? error.code}',
        );
      }

      _controller = controller;
      return CameraStartResult.ready(controller);
    } on CameraException catch (error) {
      return CameraStartResult.failure(
        CameraStartStatus.error,
        '摄像头异常：${error.description ?? error.code}',
      );
    } catch (error) {
      return CameraStartResult.failure(
        CameraStartStatus.error,
        '摄像头发生未知异常：$error',
      );
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> release() async {
    final controller = _controller;
    _controller = null;

    if (controller == null) {
      return;
    }

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (_) {
      // Keep dispose resilient even if the stream was never started.
    }

    try {
      await controller.dispose();
    } catch (_) {
      // Ignore disposal race conditions when the activity is backgrounded.
    }
  }

  CameraDescription _pickCamera(
    List<CameraDescription> cameras, {
    required CameraLensDirection preferredLensDirection,
  }) {
    return cameras.firstWhere(
      (camera) => camera.lensDirection == preferredLensDirection,
      orElse: () => cameras.first,
    );
  }

  Future<void> dispose() async {
    await release();
  }
}
