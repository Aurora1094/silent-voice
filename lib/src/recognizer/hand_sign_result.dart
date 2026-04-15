class HandSignResult {
  const HandSignResult({
    required this.label,
    required this.confidence,
    required this.handedness,
    required this.timestamp,
    required this.isStable,
  });

  final String label;
  final double confidence;
  final List<String> handedness;
  final int timestamp;
  final bool isStable;

  bool get isUnknown => label == 'unknown' || label == '未识别';

  HandSignResult copyWith({
    String? label,
    double? confidence,
    List<String>? handedness,
    int? timestamp,
    bool? isStable,
  }) {
    return HandSignResult(
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      handedness: handedness ?? this.handedness,
      timestamp: timestamp ?? this.timestamp,
      isStable: isStable ?? this.isStable,
    );
  }
}
