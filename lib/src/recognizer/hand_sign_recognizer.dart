import 'dart:collection';
import 'dart:math' as math;

import '../recognition/recognition_result.dart';
import 'hand_feature_extractor.dart';
import 'hand_sign_result.dart';

class HandSignRecognizer {
  HandSignRecognizer({
    HandFeatureExtractor? featureExtractor,
  }) : _featureExtractor = featureExtractor ?? HandFeatureExtractor();

  static const String unknownLabel = '\u672A\u8BC6\u522B';
  static const List<String> supportedLabels = <String>[
    '\u6211',
    '\u7231',
    '\u5357',
    '\u5f00',
    '\u4f60\u597d',
    '\u8c22\u8c22',
    '\u6ca1\u6709',
  ];

  final HandFeatureExtractor _featureExtractor;
  final Queue<_FramePrediction> _history = Queue<_FramePrediction>();
  final Queue<_FrameCue> _cueHistory = Queue<_FrameCue>();
  final Map<String, _MotionSample> _lastCenters = <String, _MotionSample>{};

  HandSignResult? _stableResult;

  HandSignResult process(RecognitionResult rawResult) {
    final features = _featureExtractor.extract(rawResult);
    final motion = _buildMotionFeatures(features);
    final cue = _buildCue(features);
    final prediction = _scoreFrame(features, motion);

    _history.addLast(prediction);
    while (_history.length > 5) {
      _history.removeFirst();
    }
    _cueHistory.addLast(cue);
    while (_cueHistory.length > 8) {
      _cueHistory.removeFirst();
    }

    final stabilized = _stabilize(prediction);
    _rememberCenters(features);
    _stableResult = stabilized;
    return stabilized;
  }

  void reset() {
    _history.clear();
    _cueHistory.clear();
    _lastCenters.clear();
    _stableResult = null;
  }

  _MotionFeatures _buildMotionFeatures(SignFrameFeatures features) {
    return _MotionFeatures(
      left: _movementFor('Left', features.leftHand, features.timestamp),
      right: _movementFor('Right', features.rightHand, features.timestamp),
    );
  }

  _MovementState? _movementFor(
    String handedness,
    HandFeatures? hand,
    int timestamp,
  ) {
    if (hand == null) {
      return null;
    }
    final previous = _lastCenters[handedness];
    if (previous == null) {
      return const _MovementState(direction: MovementDirection.stable, magnitude: 0);
    }
    final dx = hand.center.x - previous.x;
    final dy = hand.center.y - previous.y;
    final dt = math.max(1, timestamp - previous.timestamp);
    final normalizedDx = dx / dt * 1000;
    final normalizedDy = dy / dt * 1000;
    final magnitude = math.sqrt(
      (normalizedDx * normalizedDx) + (normalizedDy * normalizedDy),
    );

    if (magnitude < 0.12) {
      return _MovementState(direction: MovementDirection.stable, magnitude: magnitude);
    }
    if (normalizedDx.abs() >= normalizedDy.abs()) {
      return _MovementState(
        direction: normalizedDx > 0 ? MovementDirection.right : MovementDirection.left,
        magnitude: magnitude,
      );
    }
    return _MovementState(
      direction: normalizedDy > 0 ? MovementDirection.down : MovementDirection.up,
      magnitude: magnitude,
    );
  }

  _FramePrediction _scoreFrame(
    SignFrameFeatures features,
    _MotionFeatures motion,
  ) {
    final scores = <String, double>{
      '\u6211': _scoreMe(features, motion),
      '\u7231': _scoreLove(features, motion),
      '\u5357': _scoreSouth(features, motion),
      '\u5f00': _scoreOpen(features, motion),
      '\u4f60\u597d': _scoreHello(features, motion),
      '\u8c22\u8c22': _scoreThanks(features, motion),
      '\u6ca1\u6709': _scoreNothing(features, motion),
    };

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final best = sorted.first;
    final secondScore = sorted.length > 1 ? sorted[1].value : 0.0;
    final handedness = [
      if (features.leftHand != null) 'Left',
      if (features.rightHand != null) 'Right',
    ];

    final shouldBeUnknown = best.value < 0.56 || (best.value - secondScore) < 0.05;
    final label = shouldBeUnknown ? unknownLabel : best.key;
    final confidence = shouldBeUnknown
        ? math.min(0.55, best.value)
        : _confidenceFromScores(best.value, secondScore);

    return _FramePrediction(
      label: label,
      confidence: confidence,
      handedness: handedness,
      timestamp: features.timestamp,
      rawScores: scores,
    );
  }

  double _scoreHello(SignFrameFeatures features, _MotionFeatures motion) {
    final hand = features.primaryHand;
    final primaryMotion = motion.primary(features);
    if (hand == null || !features.hasSingleHand) {
      return 0;
    }

    var score = 0.04;
    score += _bonusIf(hand.isThumbOnly, 0.28);
    score += _bonusIf(_hasRecentPrimaryShape('indexOnly', within: 6), 0.34);
    score += _bonusIf(_isStableOrSmall(primaryMotion), 0.10);
    score += _rangeBonus(hand.center.x, 0.20, 0.82, 0.06);
    score += _rangeBonus(hand.center.y, 0.14, 0.62, 0.06);
    return score.clamp(0, 1);
  }

  double _scoreThanks(SignFrameFeatures features, _MotionFeatures motion) {
    final hand = features.primaryHand;
    final primaryMotion = motion.primary(features);
    if (hand == null || !features.hasSingleHand) {
      return 0;
    }

    var score = 0.10;
    score += _bonusIf(hand.isThumbOnly, 0.42);
    score += _bonusIf(primaryMotion.direction == MovementDirection.down, 0.24);
    score += _rangeBonus(primaryMotion.magnitude, 0.06, 0.88, 0.08);
    score += _rangeBonus(hand.center.y, 0.10, 0.64, 0.08);
    score += _rangeBonus(hand.center.x, 0.18, 0.82, 0.06);
    return score.clamp(0, 1);
  }

  double _scoreMe(SignFrameFeatures features, _MotionFeatures motion) {
    final hand = features.primaryHand;
    final primaryMotion = motion.primary(features);
    if (hand == null || !features.hasSingleHand) {
      return 0;
    }

    var score = 0.18;
    score += _bonusIf(hand.isIndexOnly, 0.54);
    score += _bonusIf(hand.extendedFingerCount <= 1, 0.08);
    score += _bonusIf(primaryMotion.direction == MovementDirection.stable, 0.10);
    score += _rangeBonus(hand.center.x, 0.32, 0.68, 0.08);
    score += _rangeBonus(hand.center.y, 0.32, 0.84, 0.06);
    return score.clamp(0, 1);
  }

  double _scoreLove(SignFrameFeatures features, _MotionFeatures motion) {
    if (!features.hasTwoHands) {
      return 0;
    }

    final left = features.leftHand!;
    final right = features.rightHand!;
    final leftIsThumbOnly = left.isThumbOnly;
    final rightIsThumbOnly = right.isThumbOnly;
    if (leftIsThumbOnly == rightIsThumbOnly) {
      return 0;
    }

    final thumbHand = leftIsThumbOnly ? left : right;
    final supportHand = leftIsThumbOnly ? right : left;
    final horizontalGap = (features.horizontalGap ?? 0).abs();
    final handDistance = features.handDistance ?? 0;

    var score = 0.12;
    score += 0.30;
    score += _rangeBonus(supportHand.openPalmScore, 0.20, 0.90, 0.14);
    score += _bonusIf(supportHand.extendedFingerCount >= 2, 0.10);
    score += _rangeBonus(handDistance, 0.10, 0.32, 0.14);
    score += _rangeBonus(horizontalGap, 0.02, 0.22, 0.08);
    score += _bonusIf((features.verticalGap ?? 0).abs() < 0.18, 0.06);
    score += _bonusIf(_matchesLoveStrokeMotion(motion, thumbHand.handedness), 0.12);
    return score.clamp(0, 1);
  }

  double _scoreSouth(SignFrameFeatures features, _MotionFeatures motion) {
    final hand = features.primaryHand;
    final primaryMotion = motion.primary(features);
    if (hand == null || !features.hasSingleHand) {
      return 0;
    }

    var score = 0.14;
    score += _bonusIf(hand.isDownwardTightFlatHand, 0.30);
    score += _bonusIf(hand.isTightFlatHand, 0.12);
    score += _bonusIf(hand.isFlatPalmWithThumbFolded, 0.20);
    score += _bonusIf(hand.isFlatPalm && hand.fingerSpread <= 1.02, 0.10);
    score += _bonusIf(hand.middleDirectionY >= 0.02, 0.08);
    score += _bonusIf(!hand.thumbExtended, 0.06);
    score += _bonusIf(
      primaryMotion.direction == MovementDirection.stable ||
          primaryMotion.direction == MovementDirection.down,
      0.10,
    );
    score += _rangeBonus(hand.center.x, 0.18, 0.82, 0.06);
    score += _rangeBonus(hand.center.y, 0.18, 0.88, 0.08);
    score += _bonusIf(!hand.isOpenWidePalm, 0.04);
    return score.clamp(0, 1);
  }

  double _scoreOpen(SignFrameFeatures features, _MotionFeatures motion) {
    if (!features.hasTwoHands) {
      return 0;
    }

    final left = features.leftHand!;
    final right = features.rightHand!;
    final horizontalGap = (features.horizontalGap ?? 0).abs();
    final handDistance = features.handDistance ?? 0;

    var score = 0.18;
    score += 0.18 * left.openPalmScore;
    score += 0.18 * right.openPalmScore;
    score += _bonusIf(motion.movingApartHorizontally, 0.18);
    score += _rangeBonus(horizontalGap, 0.10, 0.34, 0.10);
    score += _rangeBonus(handDistance, 0.24, 0.52, 0.10);
    score += _bonusIf((features.verticalGap ?? 0).abs() < 0.16, 0.06);
    return score.clamp(0, 1);
  }

  double _scoreUniversity(SignFrameFeatures features, _MotionFeatures motion) {
    if (!features.hasTwoHands) {
      return 0;
    }

    final left = features.leftHand!;
    final right = features.rightHand!;
    final horizontalGap = (features.horizontalGap ?? 0).abs();
    final handDistance = features.handDistance ?? 0;

    var score = 0.16;
    score += 0.18 * left.openPalmScore;
    score += 0.18 * right.openPalmScore;
    score += _rangeBonus(horizontalGap, 0.06, 0.24, 0.14);
    score += _rangeBonus(handDistance, 0.18, 0.38, 0.14);
    score += _bonusIf((features.verticalGap ?? 0).abs() < 0.20, 0.08);
    score += _bonusIf(motion.areMostlyStable || motion.movingTogetherHorizontally, 0.08);
    score += _bonusIf(left.isFlatPalm || right.isFlatPalm, 0.04);
    return score.clamp(0, 1);
  }

  double _scoreNothing(SignFrameFeatures features, _MotionFeatures motion) {
    final hand = features.primaryHand;
    final primaryMotion = motion.primary(features);
    if (hand == null || !features.hasSingleHand) {
      return 0;
    }

    final repeatedPinchCount = _countRecentPrimaryShape('pinchLike', within: 6);

    var score = 0.10;
    score += _bonusIf(hand.isPinchLike, 0.46);
    score += _bonusIf(repeatedPinchCount >= 2, 0.16);
    score += _bonusIf(_isStableOrSmall(primaryMotion, maxMagnitude: 0.32), 0.08);
    score += _bonusIf(hand.thumbIndexDistance <= 0.24, 0.08);
    score += _bonusIf(hand.thumbMiddleDistance <= 0.34, 0.08);
    score += _rangeBonus(hand.center.x, 0.22, 0.78, 0.04);
    score += _rangeBonus(hand.center.y, 0.20, 0.82, 0.06);
    return score.clamp(0, 1);
  }

  _FrameCue _buildCue(SignFrameFeatures features) {
    final hand = features.primaryHand;
    if (hand == null || !features.hasSingleHand) {
      return const _FrameCue(primaryShape: 'other');
    }
    if (hand.isIndexOnly) {
      return const _FrameCue(primaryShape: 'indexOnly');
    }
    if (hand.isThumbOnly) {
      return const _FrameCue(primaryShape: 'thumbOnly');
    }
    if (hand.isPinchLike) {
      return const _FrameCue(primaryShape: 'pinchLike');
    }
    if (hand.isDownwardTightFlatHand) {
      return const _FrameCue(primaryShape: 'downwardFlat');
    }
    if (hand.isTightFlatHand || hand.isFlatPalmWithThumbFolded) {
      return const _FrameCue(primaryShape: 'flatHand');
    }
    if (hand.isOpenWidePalm) {
      return const _FrameCue(primaryShape: 'openPalm');
    }
    return const _FrameCue(primaryShape: 'other');
  }

  int _countRecentPrimaryShape(String shape, {int within = 6}) {
    return _cueHistory.toList(growable: false).reversed.take(within).where((cue) {
      return cue.primaryShape == shape;
    }).length;
  }

  bool _hasRecentPrimaryShape(String shape, {int within = 6}) {
    return _countRecentPrimaryShape(shape, within: within) > 0;
  }

  bool _isHorizontal(_MovementState? movement) {
    return movement?.direction == MovementDirection.left ||
        movement?.direction == MovementDirection.right;
  }

  bool _isStableOrSmall(
    _MovementState? movement, {
    double maxMagnitude = 0.24,
  }) {
    if (movement == null) {
      return true;
    }
    return movement.direction == MovementDirection.stable ||
        movement.magnitude <= maxMagnitude;
  }

  bool _matchesLoveStrokeMotion(
    _MotionFeatures motion,
    String thumbHandedness,
  ) {
    final anchor = thumbHandedness == 'Left' ? motion.left : motion.right;
    final support = thumbHandedness == 'Left' ? motion.right : motion.left;
    final supportLooksLikeStroke =
        _isHorizontal(support) || support?.direction == MovementDirection.down;
    return _isStableOrSmall(anchor, maxMagnitude: 0.32) &&
        (supportLooksLikeStroke || _isStableOrSmall(support, maxMagnitude: 0.22));
  }

  double _bonusIf(bool condition, double value) {
    return condition ? value : 0.0;
  }

  double _rangeBonus(double value, double min, double max, double bonus) {
    return value >= min && value <= max ? bonus : 0.0;
  }

  double _confidenceFromScores(double topScore, double secondScore) {
    final margin = (topScore - secondScore).clamp(0.0, 1.0);
    final confidence = 0.4 + (topScore * 0.35) + (margin * 0.35);
    return confidence.clamp(0.0, 0.99);
  }

  HandSignResult _stabilize(_FramePrediction prediction) {
    final currentStable = _stableResult;

    if (_history.length < 3) {
      return currentStable ??
          HandSignResult(
            label: unknownLabel,
            confidence: 0,
            handedness: prediction.handedness,
            timestamp: prediction.timestamp,
            isStable: false,
          );
    }

    final recent = _history.toList(growable: false);
    final labelCounts = <String, int>{};
    final confidenceByLabel = <String, double>{};

    for (final item in recent) {
      labelCounts[item.label] = (labelCounts[item.label] ?? 0) + 1;
      confidenceByLabel[item.label] =
          (confidenceByLabel[item.label] ?? 0) + item.confidence;
    }

    final sortedLabels = labelCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bestLabel = sortedLabels.first.key;
    final bestCount = sortedLabels.first.value;
    final averagedConfidence =
        (confidenceByLabel[bestLabel] ?? 0) / math.max(1, bestCount);

    if (bestLabel != unknownLabel && bestCount >= 3 && prediction.label == bestLabel) {
      return HandSignResult(
        label: bestLabel,
        confidence: averagedConfidence.clamp(0.0, 0.99),
        handedness: prediction.handedness,
        timestamp: prediction.timestamp,
        isStable: true,
      );
    }

    final unknownCount = labelCounts[unknownLabel] ?? 0;
    if (unknownCount >= 4) {
      return HandSignResult(
        label: unknownLabel,
        confidence: ((confidenceByLabel[unknownLabel] ?? 0) /
                math.max(1, unknownCount))
            .clamp(0.0, 0.7),
        handedness: prediction.handedness,
        timestamp: prediction.timestamp,
        isStable: true,
      );
    }

    return currentStable?.copyWith(
          timestamp: prediction.timestamp,
          handedness: prediction.handedness,
        ) ??
        HandSignResult(
          label: unknownLabel,
          confidence: prediction.confidence * 0.5,
          handedness: prediction.handedness,
          timestamp: prediction.timestamp,
          isStable: false,
        );
  }

  void _rememberCenters(SignFrameFeatures features) {
    if (features.leftHand != null) {
      _lastCenters['Left'] = _MotionSample(
        x: features.leftHand!.center.x,
        y: features.leftHand!.center.y,
        timestamp: features.timestamp,
      );
    }
    if (features.rightHand != null) {
      _lastCenters['Right'] = _MotionSample(
        x: features.rightHand!.center.x,
        y: features.rightHand!.center.y,
        timestamp: features.timestamp,
      );
    }
  }
}

class _FramePrediction {
  const _FramePrediction({
    required this.label,
    required this.confidence,
    required this.handedness,
    required this.timestamp,
    required this.rawScores,
  });

  final String label;
  final double confidence;
  final List<String> handedness;
  final int timestamp;
  final Map<String, double> rawScores;
}

class _FrameCue {
  const _FrameCue({
    required this.primaryShape,
  });

  final String primaryShape;
}

class _MotionFeatures {
  const _MotionFeatures({
    required this.left,
    required this.right,
  });

  final _MovementState? left;
  final _MovementState? right;

  _MovementState primary(SignFrameFeatures features) {
    return right ??
        left ??
        const _MovementState(direction: MovementDirection.stable, magnitude: 0);
  }

  bool get movingApartHorizontally =>
      left?.direction == MovementDirection.left &&
      right?.direction == MovementDirection.right;

  bool get movingTogetherHorizontally =>
      left?.direction == MovementDirection.right &&
      right?.direction == MovementDirection.left;

  bool get areMostlyStable =>
      (left == null || left!.direction == MovementDirection.stable) &&
      (right == null || right!.direction == MovementDirection.stable);
}

class _MovementState {
  const _MovementState({
    required this.direction,
    required this.magnitude,
  });

  final MovementDirection direction;
  final double magnitude;
}

class _MotionSample {
  const _MotionSample({
    required this.x,
    required this.y,
    required this.timestamp,
  });

  final double x;
  final double y;
  final int timestamp;
}

enum MovementDirection {
  left,
  right,
  up,
  down,
  stable,
}
