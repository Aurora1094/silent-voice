class RecognitionLandmark {
  const RecognitionLandmark({
    required this.x,
    required this.y,
    required this.z,
  });

  final double x;
  final double y;
  final double z;

  factory RecognitionLandmark.fromMap(Map<dynamic, dynamic> map) {
    return RecognitionLandmark(
      x: _asDouble(map['x']),
      y: _asDouble(map['y']),
      z: _asDouble(map['z']),
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return 0;
  }
}

class RecognitionHand {
  const RecognitionHand({
    required this.handedness,
    required this.confidence,
    required this.landmarks,
  });

  final String handedness;
  final double confidence;
  final List<RecognitionLandmark> landmarks;

  factory RecognitionHand.fromMap(Map<dynamic, dynamic> map) {
    final landmarks = <RecognitionLandmark>[];
    final rawLandmarks = map['landmarks'];
    if (rawLandmarks is List) {
      for (final item in rawLandmarks) {
        if (item is Map) {
          landmarks.add(RecognitionLandmark.fromMap(item));
        }
      }
    }

    return RecognitionHand(
      handedness: map['handedness'] as String? ?? '未知',
      confidence: _asDouble(map['confidence']),
      landmarks: landmarks,
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return 0;
  }
}

class RecognitionResult {
  const RecognitionResult({
    required this.recognizedLabel,
    required this.confidence,
    required this.handedness,
    required this.landmarks,
    required this.hands,
    required this.timestamp,
    required this.detectorType,
    required this.isMock,
    required this.frameWidth,
    required this.frameHeight,
    required this.isFrontCamera,
  });

  final String recognizedLabel;
  final double confidence;
  final String handedness;
  final List<RecognitionLandmark> landmarks;
  final List<RecognitionHand> hands;
  final int timestamp;
  final String detectorType;
  final bool isMock;
  final int frameWidth;
  final int frameHeight;
  final bool isFrontCamera;

  int get handCount => hands.length;

  factory RecognitionResult.fromMap(Map<dynamic, dynamic> map) {
    final landmarks = <RecognitionLandmark>[];
    final rawLandmarks = map['landmarks'];
    if (rawLandmarks is List) {
      for (final item in rawLandmarks) {
        if (item is Map) {
          landmarks.add(RecognitionLandmark.fromMap(item));
        }
      }
    }

    final hands = <RecognitionHand>[];
    final rawHands = map['hands'];
    if (rawHands is List) {
      for (final item in rawHands) {
        if (item is Map) {
          hands.add(RecognitionHand.fromMap(item));
        }
      }
    }

    final compatibleHands = hands.isNotEmpty
        ? hands
        : [
            RecognitionHand(
              handedness: map['handedness'] as String? ?? '未知',
              confidence: _asDouble(map['confidence']),
              landmarks: landmarks,
            ),
          ].where((hand) => hand.landmarks.isNotEmpty).toList();

    return RecognitionResult(
      recognizedLabel: map['recognizedLabel'] as String? ?? '未知结果',
      confidence: _asDouble(map['confidence']),
      handedness: map['handedness'] as String? ?? '未知',
      landmarks: landmarks,
      hands: compatibleHands,
      timestamp: _asInt(map['timestamp']),
      detectorType: map['detectorType'] as String? ?? 'handLandmarker',
      isMock: map['isMock'] as bool? ?? false,
      frameWidth: _asInt(map['frameWidth']),
      frameHeight: _asInt(map['frameHeight']),
      isFrontCamera: map['isFrontCamera'] as bool? ?? true,
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return 0;
  }

  static int _asInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return 0;
  }
}
