import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../platform/sign_recognition_channel.dart';
import '../recognition/recognition_result.dart';
import '../recognizer/hand_sign_recognizer.dart';
import '../recognizer/hand_sign_result.dart';
import 'camera_service.dart';
import 'native_camera_preview_view.dart';

enum _PreviewStatus {
  idle,
  initializing,
  ready,
  permissionDenied,
  permissionPermanentlyDenied,
  unavailable,
  failed,
}

class EmbeddedCameraPreview extends StatefulWidget {
  const EmbeddedCameraPreview({
    super.key,
    this.targetLabel,
    this.compact = false,
  });

  final String? targetLabel;
  final bool compact;

  @override
  State<EmbeddedCameraPreview> createState() => _EmbeddedCameraPreviewState();
}

class _EmbeddedCameraPreviewState extends State<EmbeddedCameraPreview>
    with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  final SignRecognitionChannel _recognitionChannel = SignRecognitionChannel();
  final HandSignRecognizer _signRecognizer = HandSignRecognizer();

  StreamSubscription<RecognitionResult>? _recognitionSubscription;

  _PreviewStatus _status = _PreviewStatus.idle;
  String _statusMessage = '轻点下方按钮，开始相机预览。';
  RecognitionResult? _latestRecognition;
  HandSignResult? _latestSignResult;
  bool _isInitializingCamera = false;
  bool _isRecognitionRunning = false;
  bool _cameraVisible = false;

  bool get _hasTarget =>
      widget.targetLabel != null && widget.targetLabel!.trim().isNotEmpty;

  bool get _autoStart => widget.compact && _hasTarget;

  bool _matchesTarget(HandSignResult? result) {
    return _hasTarget &&
        result != null &&
        result.isStable &&
        result.label == widget.targetLabel;
  }

  String get _readyMessage {
    if (_hasTarget) {
      return '相机已开启，对准“${widget.targetLabel}”后开始识别。';
    }
    return '相机已开启，可以开始识别。';
  }

  String get _runningMessage {
    if (_hasTarget) {
      return '正在识别“${widget.targetLabel}”这个动作。';
    }
    return '正在进行课程手势关键点识别。';
  }

  String get _resumeMessage {
    if (_hasTarget) {
      return '相机已恢复，可以继续识别“${widget.targetLabel}”。';
    }
    return '相机已恢复，可以继续练习。';
  }

  String get _stoppedMessage {
    if (_hasTarget) {
      return '相机已开启，可以继续识别“${widget.targetLabel}”。';
    }
    return '相机已开启，可以继续预览。';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (_autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        unawaited(_ensureAutoStart());
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(_stopRecognition());
    }

    if (state == AppLifecycleState.resumed && mounted && _cameraVisible) {
      setState(() {
        _status = _PreviewStatus.ready;
        _statusMessage = _resumeMessage;
      });
      if (_autoStart && !_isRecognitionRunning) {
        unawaited(_startRecognition());
      }
    }
  }

  Future<void> _ensureAutoStart() async {
    if (!mounted || !_autoStart) {
      return;
    }
    if (!_cameraVisible) {
      await _openCamera();
    }
    if (!mounted || !_cameraVisible || _isRecognitionRunning) {
      return;
    }
    await _startRecognition();
  }

  Future<void> _openCamera() async {
    if (_isInitializingCamera || !mounted) {
      return;
    }

    setState(() {
      _isInitializingCamera = true;
      _status = _PreviewStatus.initializing;
      _statusMessage = '正在打开相机...';
    });

    final result = await _cameraService.ensureCameraAccess();
    if (!mounted) {
      return;
    }

    setState(() {
      _isInitializingCamera = false;
      switch (result.status) {
        case CameraStartStatus.ready:
          _cameraVisible = true;
          _status = _PreviewStatus.ready;
          _statusMessage = _readyMessage;
          break;
        case CameraStartStatus.permissionDenied:
          _status = _PreviewStatus.permissionDenied;
          _statusMessage = '还没有获得相机权限，允许后就可以开始预览。';
          break;
        case CameraStartStatus.permissionPermanentlyDenied:
          _status = _PreviewStatus.permissionPermanentlyDenied;
          _statusMessage = '相机权限已被关闭，请到系统设置里重新开启。';
          break;
        case CameraStartStatus.unavailable:
          _status = _PreviewStatus.unavailable;
          _statusMessage = '暂时没有找到可用摄像头。';
          break;
        case CameraStartStatus.error:
          _status = _PreviewStatus.failed;
          _statusMessage = result.message;
          break;
      }
    });

  }

  Future<void> _startRecognition() async {
    if (_isRecognitionRunning || !_cameraVisible || !mounted) {
      return;
    }

    try {
      _signRecognizer.reset();
      _recognitionSubscription ??= _recognitionChannel
          .recognitionResults()
          .listen(_handleRecognitionResult, onError: _handleRecognitionError);

      await _recognitionChannel.initialize(
        detectorType: SignDetectorType.handLandmarker,
        useMock: false,
      );
      await _recognitionChannel.startRecognition(
        detectorType: SignDetectorType.handLandmarker,
        useMock: false,
        interval: const Duration(milliseconds: 80),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isRecognitionRunning = true;
        _latestSignResult = null;
        _statusMessage = _runningMessage;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('识别启动失败：$error')),
      );
    }
  }

  Future<void> _stopRecognition() async {
    try {
      await _recognitionChannel.stopRecognition();
    } catch (_) {}

    if (!mounted) {
      return;
    }

    _signRecognizer.reset();
    setState(() {
      _isRecognitionRunning = false;
      _latestRecognition = null;
      _latestSignResult = null;
      if (_cameraVisible) {
        _statusMessage = _stoppedMessage;
      }
    });
  }

  void _handleRecognitionResult(RecognitionResult result) {
    if (!mounted) {
      return;
    }

    final signResult = _signRecognizer.process(result);
    final matched = _matchesTarget(signResult);
    setState(() {
      _latestRecognition = result;
      _latestSignResult = signResult;
      if (matched) {
        _statusMessage = '识别成功：${widget.targetLabel}，本次已过关。';
      }
    });
  }

  void _handleRecognitionError(Object error) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isRecognitionRunning = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('识别流异常：$error')),
    );
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final subscription = _recognitionSubscription;
    _recognitionSubscription = null;
    unawaited(subscription?.cancel() ?? Future<void>.value());
    unawaited(_recognitionChannel.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showInfoCard = !(widget.compact && _hasTarget);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPreviewCard(),
        if (showInfoCard) ...[
          const SizedBox(height: 8),
          _buildInfoCard(),
        ],
        if (!_autoStart) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: _cameraVisible ? '重新打开' : '打开摄像头',
                  onTap: _isInitializingCamera
                      ? null
                      : () {
                          unawaited(_openCamera());
                        },
                  primary: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  label: _isRecognitionRunning ? '停止识别' : '开始识别',
                  onTap: _cameraVisible
                      ? () {
                          if (_isRecognitionRunning) {
                            unawaited(_stopRecognition());
                          } else {
                            unawaited(_startRecognition());
                          }
                        }
                      : null,
                  primary: false,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      height: widget.compact ? 280 : 470,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF17263B), Color(0xFF0F1725)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E3557).withOpacity(0.16),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: switch (_status) {
          _PreviewStatus.ready => _buildLivePreview(),
          _PreviewStatus.initializing => _buildFallback(showProgress: true),
          _ => _buildFallback(),
        },
      ),
    );
  }

  Widget _buildLivePreview() {
    final signResult = _latestSignResult;
    final previewText = switch ((signResult, _hasTarget, widget.compact)) {
      (null, true, true) => '目标：${widget.targetLabel}',
      (_, true, true) when _matchesTarget(signResult) => '已过关',
      (_, true, true) => '当前：${signResult!.label}',
      (null, true, false) => '目标动作：${widget.targetLabel}，做对即可过关。',
      (null, false, _) => '相机预览正常，可以开始识别。',
      (_, true, false) when _matchesTarget(signResult) =>
        '识别成功：${widget.targetLabel}，本次已过关。',
      (_, true, false) =>
        '当前识别：${signResult!.label}，继续调整到“${widget.targetLabel}”。',
      (_, false, _) => '当前词义：${signResult!.label}  置信度：${(signResult.confidence * 100).toStringAsFixed(0)}%',
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        const NativeCameraPreviewView(),
        CustomPaint(
          painter: _LandmarkOverlayPainter(_latestRecognition),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: Colors.black.withOpacity(0.35),
            ),
            child: Text(
              previewText,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallback({bool showProgress = false}) {
    final showSettingsAction =
        _status == _PreviewStatus.permissionPermanentlyDenied;

    final icon = switch (_status) {
      _PreviewStatus.idle => Icons.videocam_outlined,
      _PreviewStatus.initializing => Icons.videocam_outlined,
      _PreviewStatus.permissionDenied => Icons.no_photography_outlined,
      _PreviewStatus.permissionPermanentlyDenied => Icons.settings_outlined,
      _PreviewStatus.unavailable => Icons.videocam_off_outlined,
      _PreviewStatus.failed => Icons.error_outline,
      _PreviewStatus.ready => Icons.videocam_outlined,
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showProgress)
              const CircularProgressIndicator(color: Colors.white)
            else
              Icon(icon, size: 42, color: Colors.white70),
            const SizedBox(height: 14),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            if (_status == _PreviewStatus.idle) ...[
              const SizedBox(height: 10),
              Text(
                '准备好时再打开就好，不会打断当前练习。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontSize: 12,
                ),
              ),
            ],
            if (_status == _PreviewStatus.permissionDenied) ...[
              const SizedBox(height: 10),
              Text(
                '你可以再次点击下方按钮，我们会重新申请权限。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.72),
                  fontSize: 12,
                ),
              ),
            ],
            if (showSettingsAction) ...[
              const SizedBox(height: 14),
              FilledButton(
                onPressed: () {
                  unawaited(_openSettings());
                },
                child: const Text('前往系统设置'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    if (widget.compact && _hasTarget) {
      return const SizedBox.shrink();
    }

    if (_hasTarget) {
      return _buildTargetInfoCard();
    }

    final rawResult = _latestRecognition;
    final signResult = _latestSignResult;
    final handednessText = signResult == null || signResult.handedness.isEmpty
        ? '无'
        : signResult.handedness.join(', ');

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.72),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            signResult == null
                ? _statusMessage
                : '手别：$handednessText  时间戳：${signResult.timestamp}  稳定：${signResult.isStable ? '是' : '否'}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF5F678F)),
          ),
          if (rawResult != null) ...[
            const SizedBox(height: 4),
            Text(
              '检测到手数：${rawResult.handCount}  总关键点：${rawResult.hands.fold<int>(0, (sum, hand) => sum + hand.landmarks.length)}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF5F678F)),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            "当前支持：${HandSignRecognizer.supportedLabels.join(' / ')}",
            style: const TextStyle(fontSize: 12, color: Color(0xFF5F678F)),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetInfoCard() {
    final rawResult = _latestRecognition;
    final signResult = _latestSignResult;
    final matched = _matchesTarget(signResult);
    final statusText = switch ((signResult, matched)) {
      (_, true) => '已过关',
      (null, _) => _isRecognitionRunning ? '识别中' : '待开始',
      _ => '继续调整',
    };
    final statusColor = matched
        ? const Color(0xFF3E8F68)
        : _isRecognitionRunning
            ? const Color(0xFFDA8A4A)
            : const Color(0xFF6A7694);

    return Container(
      padding: EdgeInsets.fromLTRB(12, widget.compact ? 8 : 10, 12, widget.compact ? 8 : 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.72),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TargetBadge(
                label: '目标动作',
                value: widget.targetLabel!,
                color: const Color(0xFF4C5D86),
              ),
              _TargetBadge(
                label: '当前状态',
                value: statusText,
                color: statusColor,
              ),
            ],
          ),
          if (!widget.compact) ...[
            const SizedBox(height: 8),
            Text(
              signResult == null
                  ? _statusMessage
                  : matched
                      ? '识别结果稳定命中“${widget.targetLabel}”，这次已经过关。'
                      : '当前识别到“${signResult.label}”，继续调整到目标动作“${widget.targetLabel}”。',
              style: const TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Color(0xFF5F678F),
              ),
            ),
          ],
          if (!widget.compact && (rawResult != null || signResult != null)) ...[
            const SizedBox(height: 6),
            Text(
              '稳定：${signResult?.isStable == true ? '是' : '否'}  手数：${rawResult?.handCount ?? 0}  时间戳：${signResult?.timestamp ?? '--'}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF7A86A3)),
            ),
          ],
        ],
      ),
    );
  }
}

class _TargetBadge extends StatelessWidget {
  const _TargetBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(0.10),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Color(0xFF5F678F)),
          children: [
            TextSpan(
              text: '$label ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.primary,
  });

  final String label;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: primary
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFB9A3), Color(0xFFFFCFC1)],
                  )
                : null,
            color: primary ? null : Colors.white.withOpacity(0.62),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E3557).withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: primary
                  ? const Color(0xFF2E3557)
                  : const Color(0xFF5F678F),
            ),
          ),
        ),
      ),
    );
  }
}

class _LandmarkOverlayPainter extends CustomPainter {
  const _LandmarkOverlayPainter(this.result);

  final RecognitionResult? result;

  static const List<List<int>> _connections = [
    [0, 1], [1, 2], [2, 3], [3, 4],
    [0, 5], [5, 6], [6, 7], [7, 8],
    [5, 9], [9, 10], [10, 11], [11, 12],
    [9, 13], [13, 14], [14, 15], [15, 16],
    [13, 17], [17, 18], [18, 19], [19, 20],
    [0, 17],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final result = this.result;
    final hands = result?.hands ?? const <RecognitionHand>[];
    if (result == null || hands.isEmpty) {
      return;
    }

    final frameWidth =
        result.frameWidth > 0 ? result.frameWidth.toDouble() : size.width;
    final frameHeight =
        result.frameHeight > 0 ? result.frameHeight.toDouble() : size.height;
    final scale = math.max(size.width / frameWidth, size.height / frameHeight);
    final fittedWidth = frameWidth * scale;
    final fittedHeight = frameHeight * scale;
    final dx = (size.width - fittedWidth) / 2;
    final dy = (size.height - fittedHeight) / 2;

    const handColors = <Color>[
      Color(0xAA81D4FA),
      Color(0xAAF8BBD0),
    ];
    const pointColors = <Color>[
      Color(0xFFFFF59D),
      Color(0xFFA5D6A7),
    ];

    for (var handIndex = 0; handIndex < hands.length; handIndex++) {
      final hand = hands[handIndex];
      final points = hand.landmarks.map((landmark) {
        final rotatedX = 1 - landmark.y;
        final rotatedY = landmark.x;
        final x = rotatedX;
        final y = 1 - rotatedY;
        return Offset(
          dx + x * fittedWidth,
          dy + y * fittedHeight,
        );
      }).toList();

      final linePaint = Paint()
        ..color = handColors[handIndex % handColors.length]
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final pointPaint = Paint()
        ..color = pointColors[handIndex % pointColors.length]
        ..style = PaintingStyle.fill;

      for (final connection in _connections) {
        if (connection[0] >= points.length || connection[1] >= points.length) {
          continue;
        }
        canvas.drawLine(points[connection[0]], points[connection[1]], linePaint);
      }

      for (var index = 0; index < points.length; index++) {
        final point = points[index];
        canvas.drawCircle(point, 5, pointPaint);

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${handIndex + 1}-$index',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(canvas, point + const Offset(6, -6));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LandmarkOverlayPainter oldDelegate) {
    return oldDelegate.result != result;
  }
}
