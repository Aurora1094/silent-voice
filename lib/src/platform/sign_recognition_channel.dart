import 'package:flutter/services.dart';

import '../recognition/recognition_result.dart';

enum SignDetectorType {
  handLandmarker,
  gestureRecognizer,
}

extension on SignDetectorType {
  String get platformValue {
    switch (this) {
      case SignDetectorType.handLandmarker:
        return 'handLandmarker';
      case SignDetectorType.gestureRecognizer:
        return 'gestureRecognizer';
    }
  }
}

class SignRecognitionChannel {
  static const MethodChannel _methodChannel = MethodChannel(
    'silent_voice/sign_recognition_method',
  );
  static const EventChannel _eventChannel = EventChannel(
    'silent_voice/sign_recognition_events',
  );

  Stream<RecognitionResult>? _resultStream;

  Stream<RecognitionResult> recognitionResults() {
    return _resultStream ??= _eventChannel
        .receiveBroadcastStream()
        .where((event) => event is Map)
        .map(
          (event) => RecognitionResult.fromMap(
            Map<dynamic, dynamic>.from(event as Map),
          ),
        )
        .asBroadcastStream();
  }

  Future<void> initialize({
    SignDetectorType detectorType = SignDetectorType.handLandmarker,
    bool useMock = true,
  }) async {
    await _invokeVoid(
      'initialize',
      <String, dynamic>{
        'detectorType': detectorType.platformValue,
        'useMock': useMock,
      },
    );
  }

  Future<void> startRecognition({
    SignDetectorType detectorType = SignDetectorType.handLandmarker,
    bool useMock = true,
    Duration interval = const Duration(milliseconds: 1200),
  }) async {
    await _invokeVoid(
      'startRecognition',
      <String, dynamic>{
        'detectorType': detectorType.platformValue,
        'useMock': useMock,
        'intervalMs': interval.inMilliseconds,
      },
    );
  }

  Future<void> stopRecognition() async {
    await _invokeVoid('stopRecognition');
  }

  Future<void> dispose() async {
    await _invokeVoid('dispose');
  }

  Future<void> _invokeVoid(String method, [Map<String, dynamic>? arguments]) async {
    try {
      await _methodChannel.invokeMethod<void>(method, arguments);
    } on PlatformException catch (error) {
      throw Exception(
        '原生通道调用失败（$method）：${error.code} ${error.message}',
      );
    }
  }
}
