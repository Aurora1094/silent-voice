import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../platform/sign_recognition_channel.dart';
import '../recognition/recognition_result.dart';
import 'camera_service.dart';

enum _CameraPageStatus {
  initializing,
  ready,
  permissionDenied,
  permissionPermanentlyDenied,
  unavailable,
  error,
}

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  final SignRecognitionChannel _recognitionChannel = SignRecognitionChannel();

  StreamSubscription<RecognitionResult>? _recognitionSubscription;

  _CameraPageStatus _status = _CameraPageStatus.initializing;
  String _statusMessage = 'Preparing camera...';
  RecognitionResult? _latestRecognition;
  bool _isInitializingCamera = false;
  bool _isRecognitionRunning = false;
  bool _isRecognitionBusy = false;
  SignDetectorType _selectedDetector = SignDetectorType.handLandmarker;
  bool _useMockRecognition = true;

  CameraController? get _controller => _cameraService.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initializeCamera());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    unawaited(_handleLifecycleStateChange(state));
  }

  Future<void> _handleLifecycleStateChange(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await _initializeCamera(fromLifecycle: true);
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      await _stopRecognition();
      await _cameraService.release();
      if (!mounted) {
        return;
      }
      setState(() {
        _status = _CameraPageStatus.initializing;
        _statusMessage = 'Camera preview paused while the app is in background.';
      });
    }
  }

  Future<void> _initializeCamera({bool fromLifecycle = false}) async {
    if (_isInitializingCamera || !mounted) {
      return;
    }

    setState(() {
      _isInitializingCamera = true;
      _status = _CameraPageStatus.initializing;
      _statusMessage = fromLifecycle
          ? 'Restoring camera preview...'
          : 'Preparing camera...';
    });

    final result = await _cameraService.initializePreview();
    if (!mounted) {
      _isInitializingCamera = false;
      return;
    }

    setState(() {
      _isInitializingCamera = false;
      switch (result.status) {
        case CameraStartStatus.ready:
          _status = _CameraPageStatus.ready;
          _statusMessage = result.message;
          break;
        case CameraStartStatus.permissionDenied:
          _status = _CameraPageStatus.permissionDenied;
          _statusMessage = result.message;
          break;
        case CameraStartStatus.permissionPermanentlyDenied:
          _status = _CameraPageStatus.permissionPermanentlyDenied;
          _statusMessage = result.message;
          break;
        case CameraStartStatus.unavailable:
          _status = _CameraPageStatus.unavailable;
          _statusMessage = result.message;
          break;
        case CameraStartStatus.error:
          _status = _CameraPageStatus.error;
          _statusMessage = result.message;
          break;
      }
    });
  }

  Future<void> _startMockRecognition() async {
    if (_isRecognitionRunning || _isRecognitionBusy || !mounted) {
      return;
    }

    setState(() {
      _isRecognitionBusy = true;
    });

    try {
      _recognitionSubscription ??= _recognitionChannel
          .recognitionResults()
          .listen(_handleRecognitionResult, onError: _handleRecognitionError);

      await _recognitionChannel.initialize(
        detectorType: _selectedDetector,
        useMock: _useMockRecognition,
      );
      await _recognitionChannel.startRecognition(
        detectorType: _selectedDetector,
        useMock: _useMockRecognition,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isRecognitionRunning = true;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recognition channel failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRecognitionBusy = false;
        });
      } else {
        _isRecognitionBusy = false;
      }
    }
  }

  Future<void> _stopRecognition() async {
    if (!_isRecognitionRunning && !_isRecognitionBusy) {
      return;
    }

    try {
      await _recognitionChannel.stopRecognition();
    } catch (_) {
      // Ignore platform errors while the page is being torn down.
    }

    if (!mounted) {
      _isRecognitionRunning = false;
      _isRecognitionBusy = false;
      return;
    }

    setState(() {
      _isRecognitionRunning = false;
      _isRecognitionBusy = false;
    });
  }

  void _handleRecognitionResult(RecognitionResult result) {
    if (!mounted) {
      return;
    }
    setState(() {
      _latestRecognition = result;
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
      SnackBar(content: Text('Recognition stream error: $error')),
    );
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  Future<void> _switchDetector(SignDetectorType detectorType) async {
    if (_selectedDetector == detectorType) {
      return;
    }

    final shouldRestart = _isRecognitionRunning;
    if (shouldRestart) {
      await _stopRecognition();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedDetector = detectorType;
      _latestRecognition = null;
    });

    if (shouldRestart) {
      await _startMockRecognition();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final subscription = _recognitionSubscription;
    _recognitionSubscription = null;
    unawaited(subscription?.cancel() ?? Future<void>.value());
    unawaited(_recognitionChannel.dispose());
    unawaited(_cameraService.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Preview'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildPreviewCard(),
              ),
              const SizedBox(height: 16),
              _buildStatusCard(),
              const SizedBox(height: 12),
              _buildRecognitionCard(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _isInitializingCamera
                          ? null
                          : () {
                              unawaited(_initializeCamera());
                            },
                      child: const Text('Retry camera'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _status == _CameraPageStatus.ready
                          ? () {
                              if (_isRecognitionRunning) {
                                unawaited(_stopRecognition());
                              } else {
                                unawaited(_startMockRecognition());
                              }
                            }
                          : null,
                      child: Text(
                        _isRecognitionRunning
                            ? 'Stop mock recognition'
                            : 'Start mock recognition',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: switch (_status) {
            _CameraPageStatus.ready => _buildCameraPreview(),
            _ => _buildFallbackState(),
          },
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return _buildFallbackState();
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildFallbackState() {
    final showSettingsAction =
        _status == _CameraPageStatus.permissionPermanentlyDenied;

    final icon = switch (_status) {
      _CameraPageStatus.initializing => Icons.cameraswitch_outlined,
      _CameraPageStatus.permissionDenied => Icons.no_photography_outlined,
      _CameraPageStatus.permissionPermanentlyDenied =>
        Icons.settings_outlined,
      _CameraPageStatus.unavailable => Icons.videocam_off_outlined,
      _CameraPageStatus.error => Icons.error_outline,
      _CameraPageStatus.ready => Icons.videocam_outlined,
    };

    return Center(
      key: ValueKey<_CameraPageStatus>(_status),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_status == _CameraPageStatus.initializing)
              const CircularProgressIndicator(),
            if (_status != _CameraPageStatus.initializing)
              Icon(icon, size: 48, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (showSettingsAction) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  unawaited(_openSettings());
                },
                child: const Text('Open settings'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusText = switch (_status) {
      _CameraPageStatus.initializing => 'Initializing',
      _CameraPageStatus.ready => 'Ready',
      _CameraPageStatus.permissionDenied => 'Permission denied',
      _CameraPageStatus.permissionPermanentlyDenied => 'Permission blocked',
      _CameraPageStatus.unavailable => 'Camera unavailable',
      _CameraPageStatus.error => 'Initialization failed',
    };

    return Card(
      child: ListTile(
        title: const Text('Camera state'),
        subtitle: Text(_statusMessage),
        trailing: Text(statusText),
      ),
    );
  }

  Widget _buildRecognitionCard() {
    final result = _latestRecognition;
    final subtitle = result == null
        ? 'Native recognition channel is ready, but still using mock data.'
        : 'label=${result.recognizedLabel}, confidence=${result.confidence.toStringAsFixed(2)}, handedness=${result.handedness}, landmarks=${result.landmarks.length}, timestamp=${result.timestamp}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recognition bridge',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: SignDetectorType.values.map((detectorType) {
                return ChoiceChip(
                  label: Text(_detectorLabel(detectorType)),
                  selected: _selectedDetector == detectorType,
                  onSelected: (selected) {
                    if (!selected) {
                      return;
                    }
                    unawaited(_switchDetector(detectorType));
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use mock recognition'),
              subtitle: Text(
                _useMockRecognition
                    ? 'Current safe mode. Camera preview stays isolated from native inference.'
                    : 'Use Android native MediaPipe engine when the selected model asset exists.',
              ),
              value: _useMockRecognition,
              onChanged: (value) {
                final shouldRestart = _isRecognitionRunning;
                setState(() {
                  _useMockRecognition = value;
                  _latestRecognition = null;
                });
                if (shouldRestart) {
                  unawaited(_stopRecognition().then((_) => _startMockRecognition()));
                }
              },
            ),
            const SizedBox(height: 4),
            Text(subtitle),
            const SizedBox(height: 8),
            Text(
              'Detector: ${result?.detectorType ?? _detectorLabel(_selectedDetector)} | Mock: ${result?.isMock ?? true}',
            ),
          ],
        ),
      ),
    );
  }

  String _detectorLabel(SignDetectorType detectorType) {
    switch (detectorType) {
      case SignDetectorType.handLandmarker:
        return 'handLandmarker';
      case SignDetectorType.gestureRecognizer:
        return 'gestureRecognizer';
    }
  }
}
