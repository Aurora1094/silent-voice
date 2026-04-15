import 'dart:math' as math;

import '../recognition/recognition_result.dart';

class HandFeatureExtractor {
  SignFrameFeatures extract(RecognitionResult result) {
    final handsBySide = _assignHands(result.hands);
    final leftHand = handsBySide['Left'];
    final rightHand = handsBySide['Right'];

    return SignFrameFeatures(
      timestamp: result.timestamp,
      leftHand: leftHand,
      rightHand: rightHand,
      handDistance: leftHand != null && rightHand != null
          ? _distance(leftHand.center, rightHand.center)
          : null,
      horizontalGap: leftHand != null && rightHand != null
          ? rightHand.center.x - leftHand.center.x
          : null,
      verticalGap: leftHand != null && rightHand != null
          ? rightHand.center.y - leftHand.center.y
          : null,
    );
  }

  Map<String, HandFeatures> _assignHands(List<RecognitionHand> rawHands) {
    final normalized = rawHands.map(_buildHandFeatures).toList();
    final bySide = <String, HandFeatures>{};

    for (final hand in normalized) {
      if (hand.handedness == 'Left' || hand.handedness == 'Right') {
        bySide[hand.handedness] = hand;
      }
    }

    if (bySide.length == normalized.length) {
      return bySide;
    }

    final remaining = normalized.where((hand) => !bySide.containsValue(hand)).toList()
      ..sort((a, b) => a.center.x.compareTo(b.center.x));

    if (!bySide.containsKey('Left') && remaining.isNotEmpty) {
      bySide['Left'] = remaining.removeAt(0).copyWith(handedness: 'Left');
    }
    if (!bySide.containsKey('Right') && remaining.isNotEmpty) {
      bySide['Right'] = remaining.removeAt(0).copyWith(handedness: 'Right');
    }

    return bySide;
  }

  HandFeatures _buildHandFeatures(RecognitionHand hand) {
    final landmarks = hand.landmarks;
    if (landmarks.length < 21) {
      return HandFeatures.empty(_normalizeHandedness(hand.handedness));
    }

    final wrist = landmarks[_LandmarkIndex.wrist];
    final indexMcp = landmarks[_LandmarkIndex.indexMcp];
    final pinkyMcp = landmarks[_LandmarkIndex.pinkyMcp];
    final middleMcp = landmarks[_LandmarkIndex.middleMcp];
    final palmCenter = _center([wrist, indexMcp, pinkyMcp, middleMcp]);
    final scale = math.max(
      0.0001,
      math.max(
        _distance(wrist, middleMcp),
        _distance(indexMcp, pinkyMcp),
      ),
    );

    final normalizedLandmarks = landmarks
        .map(
          (point) => NormalizedPoint(
            x: (point.x - wrist.x) / scale,
            y: (point.y - wrist.y) / scale,
            z: (point.z - wrist.z) / scale,
          ),
        )
        .toList(growable: false);

    final indexExtended = _isFingerExtended(
      landmarks[_LandmarkIndex.indexMcp],
      landmarks[_LandmarkIndex.indexPip],
      landmarks[_LandmarkIndex.indexDip],
      landmarks[_LandmarkIndex.indexTip],
      wrist,
      scale,
    );
    final middleExtended = _isFingerExtended(
      landmarks[_LandmarkIndex.middleMcp],
      landmarks[_LandmarkIndex.middlePip],
      landmarks[_LandmarkIndex.middleDip],
      landmarks[_LandmarkIndex.middleTip],
      wrist,
      scale,
    );
    final ringExtended = _isFingerExtended(
      landmarks[_LandmarkIndex.ringMcp],
      landmarks[_LandmarkIndex.ringPip],
      landmarks[_LandmarkIndex.ringDip],
      landmarks[_LandmarkIndex.ringTip],
      wrist,
      scale,
    );
    final pinkyExtended = _isFingerExtended(
      landmarks[_LandmarkIndex.pinkyMcp],
      landmarks[_LandmarkIndex.pinkyPip],
      landmarks[_LandmarkIndex.pinkyDip],
      landmarks[_LandmarkIndex.pinkyTip],
      wrist,
      scale,
    );
    final thumbExtended = _isThumbExtended(landmarks, wrist, scale);
    final thumbOutward = _isThumbOutward(landmarks, hand.handedness);
    final palmOrientation = _computePalmOrientation(wrist, indexMcp, pinkyMcp);
    final openPalmScore = [
      thumbExtended,
      indexExtended,
      middleExtended,
      ringExtended,
      pinkyExtended,
    ].where((flag) => flag).length / 5.0;

    return HandFeatures(
      handedness: _normalizeHandedness(hand.handedness),
      rawLandmarks: landmarks,
      normalizedLandmarks: normalizedLandmarks,
      center: palmCenter,
      palmWidth: _distance(indexMcp, pinkyMcp),
      indexExtended: indexExtended,
      middleExtended: middleExtended,
      ringExtended: ringExtended,
      pinkyExtended: pinkyExtended,
      thumbExtended: thumbExtended,
      thumbOutward: thumbOutward,
      palmOrientation: palmOrientation,
      openPalmScore: openPalmScore,
    );
  }

  bool _isFingerExtended(
    RecognitionLandmark mcp,
    RecognitionLandmark pip,
    RecognitionLandmark dip,
    RecognitionLandmark tip,
    RecognitionLandmark wrist,
    double scale,
  ) {
    final wristToTip = _distance(wrist, tip) / scale;
    final wristToPip = _distance(wrist, pip) / scale;
    final bend = _angle(mcp, pip, tip);
    return wristToTip > wristToPip + 0.28 && bend > 150;
  }

  bool _isThumbExtended(
    List<RecognitionLandmark> landmarks,
    RecognitionLandmark wrist,
    double scale,
  ) {
    final tip = landmarks[_LandmarkIndex.thumbTip];
    final ip = landmarks[_LandmarkIndex.thumbIp];
    final mcp = landmarks[_LandmarkIndex.thumbMcp];
    final wristToTip = _distance(wrist, tip) / scale;
    final wristToIp = _distance(wrist, ip) / scale;
    final bend = _angle(mcp, ip, tip);
    return wristToTip > wristToIp + 0.18 && bend > 135;
  }

  bool _isThumbOutward(List<RecognitionLandmark> landmarks, String handedness) {
    final thumbTip = landmarks[_LandmarkIndex.thumbTip];
    final indexMcp = landmarks[_LandmarkIndex.indexMcp];
    final normalized = _normalizeHandedness(handedness);
    if (normalized == 'Left') {
      return thumbTip.x < indexMcp.x;
    }
    return thumbTip.x > indexMcp.x;
  }

  double _computePalmOrientation(
    RecognitionLandmark wrist,
    RecognitionLandmark indexMcp,
    RecognitionLandmark pinkyMcp,
  ) {
    final ax = indexMcp.x - wrist.x;
    final ay = indexMcp.y - wrist.y;
    final bx = pinkyMcp.x - wrist.x;
    final by = pinkyMcp.y - wrist.y;
    return (ax * by) - (ay * bx);
  }

  String _normalizeHandedness(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('left') || raw.contains('\u5DE6')) {
      return 'Left';
    }
    if (lower.contains('right') || raw.contains('\u53F3')) {
      return 'Right';
    }
    return 'Unknown';
  }

  static RecognitionLandmark _center(List<RecognitionLandmark> points) {
    final x = points.map((point) => point.x).reduce((a, b) => a + b) / points.length;
    final y = points.map((point) => point.y).reduce((a, b) => a + b) / points.length;
    final z = points.map((point) => point.z).reduce((a, b) => a + b) / points.length;
    return RecognitionLandmark(x: x, y: y, z: z);
  }

  static double _distance(RecognitionLandmark a, RecognitionLandmark b) {
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    final dz = a.z - b.z;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  static double _angle(
    RecognitionLandmark a,
    RecognitionLandmark b,
    RecognitionLandmark c,
  ) {
    final abx = a.x - b.x;
    final aby = a.y - b.y;
    final cbx = c.x - b.x;
    final cby = c.y - b.y;
    final dot = (abx * cbx) + (aby * cby);
    final mag1 = math.sqrt((abx * abx) + (aby * aby));
    final mag2 = math.sqrt((cbx * cbx) + (cby * cby));
    if (mag1 == 0 || mag2 == 0) {
      return 0;
    }
    final cosine = (dot / (mag1 * mag2)).clamp(-1.0, 1.0);
    return math.acos(cosine) * 180 / math.pi;
  }
}

class SignFrameFeatures {
  const SignFrameFeatures({
    required this.timestamp,
    required this.leftHand,
    required this.rightHand,
    required this.handDistance,
    required this.horizontalGap,
    required this.verticalGap,
  });

  final int timestamp;
  final HandFeatures? leftHand;
  final HandFeatures? rightHand;
  final double? handDistance;
  final double? horizontalGap;
  final double? verticalGap;

  bool get hasSingleHand => (leftHand != null) ^ (rightHand != null);
  bool get hasTwoHands => leftHand != null && rightHand != null;
  HandFeatures? get primaryHand => rightHand ?? leftHand;
}

class HandFeatures {
  const HandFeatures({
    required this.handedness,
    required this.rawLandmarks,
    required this.normalizedLandmarks,
    required this.center,
    required this.palmWidth,
    required this.indexExtended,
    required this.middleExtended,
    required this.ringExtended,
    required this.pinkyExtended,
    required this.thumbExtended,
    required this.thumbOutward,
    required this.palmOrientation,
    required this.openPalmScore,
  });

  final String handedness;
  final List<RecognitionLandmark> rawLandmarks;
  final List<NormalizedPoint> normalizedLandmarks;
  final RecognitionLandmark center;
  final double palmWidth;
  final bool indexExtended;
  final bool middleExtended;
  final bool ringExtended;
  final bool pinkyExtended;
  final bool thumbExtended;
  final bool thumbOutward;
  final double palmOrientation;
  final double openPalmScore;

  factory HandFeatures.empty(String handedness) {
    return HandFeatures(
      handedness: handedness,
      rawLandmarks: const [],
      normalizedLandmarks: const [],
      center: const RecognitionLandmark(x: 0, y: 0, z: 0),
      palmWidth: 0,
      indexExtended: false,
      middleExtended: false,
      ringExtended: false,
      pinkyExtended: false,
      thumbExtended: false,
      thumbOutward: false,
      palmOrientation: 0,
      openPalmScore: 0,
    );
  }

  HandFeatures copyWith({
    String? handedness,
  }) {
    return HandFeatures(
      handedness: handedness ?? this.handedness,
      rawLandmarks: rawLandmarks,
      normalizedLandmarks: normalizedLandmarks,
      center: center,
      palmWidth: palmWidth,
      indexExtended: indexExtended,
      middleExtended: middleExtended,
      ringExtended: ringExtended,
      pinkyExtended: pinkyExtended,
      thumbExtended: thumbExtended,
      thumbOutward: thumbOutward,
      palmOrientation: palmOrientation,
      openPalmScore: openPalmScore,
    );
  }

  int get extendedFingerCount => [
        thumbExtended,
        indexExtended,
        middleExtended,
        ringExtended,
        pinkyExtended,
      ].where((flag) => flag).length;

  bool get isOpenPalm => openPalmScore >= 0.8;
  bool get isIndexOnly =>
      indexExtended &&
      !middleExtended &&
      !ringExtended &&
      !pinkyExtended &&
      !thumbExtended;
  bool get isThumbsUp =>
      thumbExtended &&
      thumbOutward &&
      !indexExtended &&
      !middleExtended &&
      !ringExtended &&
      !pinkyExtended;
}

class NormalizedPoint {
  const NormalizedPoint({
    required this.x,
    required this.y,
    required this.z,
  });

  final double x;
  final double y;
  final double z;
}

abstract final class _LandmarkIndex {
  static const int wrist = 0;
  static const int thumbMcp = 2;
  static const int thumbIp = 3;
  static const int thumbTip = 4;
  static const int indexMcp = 5;
  static const int indexPip = 6;
  static const int indexDip = 7;
  static const int indexTip = 8;
  static const int middleMcp = 9;
  static const int middlePip = 10;
  static const int middleDip = 11;
  static const int middleTip = 12;
  static const int ringMcp = 13;
  static const int ringPip = 14;
  static const int ringDip = 15;
  static const int ringTip = 16;
  static const int pinkyMcp = 17;
  static const int pinkyPip = 18;
  static const int pinkyDip = 19;
  static const int pinkyTip = 20;
}
