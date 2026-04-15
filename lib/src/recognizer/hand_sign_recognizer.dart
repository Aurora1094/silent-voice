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

  final HandFeatureExtractor _featureExtractor;
  final Queue<_FramePrediction> _history = Queue<_FramePrediction>();
  final Map<String, _MotionSample> _lastCenters = <String, _MotionSample>{};

  HandSignResult? _stableResult;

  HandSignResult process(RecognitionResult rawResult) {
    final features = _featureExtractor.extract(rawResult);
    final motion = _buildMotionFeatures(features);
    final prediction = _scoreFrame(features, motion);

    _history.addLast(prediction);
    while (_history.length > 5) {
      _history.removeFirst();
    }

    final stabilized = _stabilize(prediction);
    _rememberCenters(features);
    _stableResult = stabilized;
    return stabilized;
  }

  void reset() {
    _history.clear();
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
      '\u4F60\u597D': _scoreThanks(features, motion),
      '\u8C22\u8C22': _scoreHello(features, motion),
      '\u6211': _scoreMe(features, motion),
      '\u559C\u6B22': _scoreLike(features, motion),
      '\u518D\u89C1': _scoreGoodbye(features, motion),
    };

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final best = sorted.first;
    final secondScore = sorted.length > 1 ? sorted[1].value : 0.0;
    final handedness = [
      if (features.leftHand != null) 'Left',
      if (features.rightHand != null) 'Right',
    ];

    final shouldBeUnknown = best.value < 0.62 || (best.value - secondScore) < 0.08;
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
    if (hand == null) {
      return 0;
    }

    var score = 0.0;
    if (features.hasSingleHand) score += 0.18;
    score += 0.42 * hand.openPalmScore;
    if (primaryMotion.direction == MovementDirection.left ||
        primaryMotion.direction == MovementDirection.right) {
      score += 0.28;
    }
    if (primaryMotion.magnitude > 0.14 && primaryMotion.magnitude < 1.1) {
      score += 0.12;
    }
    return score.clamp(0, 1);
  }

  double _scoreThanks(SignFrameFeatures features, _MotionFeatures motion) {
    final hand = features.primaryHand;
    final primaryMotion = motion.primary(features);
    if (hand == null) {
      return 0;
    }

    var score = 0.0;
    if (features.hasSingleHand) score += 0.16;
    score += 0.44 * hand.openPalmScore;
    if (primaryMotion.direction == MovementDirection.down) {
      score += 0.28;
    }
    if (primaryMotion.magnitude > 0.12 && primaryMotion.magnitude < 1.0) {
      score += 0.12;
    }
    return score.clamp(0, 1);
  }

  double _scoreMe(SignFrameFeatures features, _MotionFeatures motion) {
    final hand = features.primaryHand;
    final primaryMotion = motion.primary(features);
    if (hand == null) {
      return 0;
    }

    var score = 0.0;
    if (features.hasSingleHand) score += 0.18;
    if (hand.isIndexOnly) score += 0.62;
    if (primaryMotion.direction == MovementDirection.stable) score += 0.12;
    if (hand.palmWidth > 0) score += 0.08;
    return score.clamp(0, 1);
  }

  double _scoreLike(SignFrameFeatures features, _MotionFeatures motion) {
    final hand = features.primaryHand;
    final primaryMotion = motion.primary(features);
    if (hand == null) {
      return 0;
    }

    var score = 0.0;
    if (features.hasSingleHand) score += 0.16;
    if (hand.isThumbsUp) score += 0.66;
    if (primaryMotion.direction == MovementDirection.stable) score += 0.10;
    if (hand.thumbOutward) score += 0.08;
    return score.clamp(0, 1);
  }

  double _scoreGoodbye(SignFrameFeatures features, _MotionFeatures motion) {
    if (!features.hasTwoHands) {
      return 0;
    }

    final left = features.leftHand!;
    final right = features.rightHand!;
    var score = 0.0;
    score += 0.20;
    score += 0.26 * left.openPalmScore;
    score += 0.26 * right.openPalmScore;
    if ((features.handDistance ?? 0) > 0.22) score += 0.14;
    if ((features.horizontalGap ?? 0) > 0.06) score += 0.08;
    if (motion.left?.direction == MovementDirection.left &&
        motion.right?.direction == MovementDirection.right) {
      score += 0.06;
    }
    return score.clamp(0, 1);
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
