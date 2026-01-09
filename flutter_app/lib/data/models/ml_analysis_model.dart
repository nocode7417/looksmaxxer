import 'dart:ui';
import '../../core/constants/app_constants.dart';

/// A 2D point representing a facial landmark
class FacialPoint {
  final double x;
  final double y;

  const FacialPoint(this.x, this.y);

  /// Calculate distance to another point
  double distanceTo(FacialPoint other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return (dx * dx + dy * dy).sqrt();
  }

  /// Calculate midpoint between two points
  FacialPoint midpointTo(FacialPoint other) {
    return FacialPoint((x + other.x) / 2, (y + other.y) / 2);
  }

  /// Convert to Offset for drawing
  Offset toOffset() => Offset(x, y);

  Map<String, dynamic> toMap() => {'x': x, 'y': y};

  factory FacialPoint.fromMap(Map<String, dynamic> map) {
    return FacialPoint(
      (map['x'] as num).toDouble(),
      (map['y'] as num).toDouble(),
    );
  }
}

/// Collection of facial landmarks from ML Kit
class FacialLandmarks {
  final List<FacialPoint> leftEyePoints;
  final List<FacialPoint> rightEyePoints;
  final List<FacialPoint> nosePoints;
  final List<FacialPoint> mouthPoints;
  final List<FacialPoint> faceContourPoints;
  final List<FacialPoint> leftEyebrowPoints;
  final List<FacialPoint> rightEyebrowPoints;

  FacialLandmarks({
    required this.leftEyePoints,
    required this.rightEyePoints,
    required this.nosePoints,
    required this.mouthPoints,
    required this.faceContourPoints,
    required this.leftEyebrowPoints,
    required this.rightEyebrowPoints,
  });

  /// Left eye center
  FacialPoint? get leftEyeCenter {
    if (leftEyePoints.isEmpty) return null;
    final sumX = leftEyePoints.fold<double>(0, (sum, p) => sum + p.x);
    final sumY = leftEyePoints.fold<double>(0, (sum, p) => sum + p.y);
    return FacialPoint(sumX / leftEyePoints.length, sumY / leftEyePoints.length);
  }

  /// Right eye center
  FacialPoint? get rightEyeCenter {
    if (rightEyePoints.isEmpty) return null;
    final sumX = rightEyePoints.fold<double>(0, (sum, p) => sum + p.x);
    final sumY = rightEyePoints.fold<double>(0, (sum, p) => sum + p.y);
    return FacialPoint(sumX / rightEyePoints.length, sumY / rightEyePoints.length);
  }

  /// Interocular distance (distance between eye centers)
  double? get interocularDistance {
    final left = leftEyeCenter;
    final right = rightEyeCenter;
    if (left == null || right == null) return null;
    return left.distanceTo(right);
  }

  /// Face width (from contour)
  double? get facialWidth {
    if (faceContourPoints.isEmpty) return null;
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    for (final point in faceContourPoints) {
      if (point.x < minX) minX = point.x;
      if (point.x > maxX) maxX = point.x;
    }
    return maxX - minX;
  }

  /// Face height (from contour)
  double? get facialHeight {
    if (faceContourPoints.isEmpty) return null;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    for (final point in faceContourPoints) {
      if (point.y < minY) minY = point.y;
      if (point.y > maxY) maxY = point.y;
    }
    return maxY - minY;
  }

  /// Nose tip position
  FacialPoint? get noseTip {
    if (nosePoints.isEmpty) return null;
    // Nose tip is typically the lowest point
    return nosePoints.reduce((a, b) => a.y > b.y ? a : b);
  }

  /// Mouth center
  FacialPoint? get mouthCenter {
    if (mouthPoints.isEmpty) return null;
    final sumX = mouthPoints.fold<double>(0, (sum, p) => sum + p.x);
    final sumY = mouthPoints.fold<double>(0, (sum, p) => sum + p.y);
    return FacialPoint(sumX / mouthPoints.length, sumY / mouthPoints.length);
  }

  /// Mouth width
  double? get mouthWidth {
    if (mouthPoints.isEmpty) return null;
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    for (final point in mouthPoints) {
      if (point.x < minX) minX = point.x;
      if (point.x > maxX) maxX = point.x;
    }
    return maxX - minX;
  }

  Map<String, dynamic> toMap() {
    return {
      'leftEyePoints': leftEyePoints.map((p) => p.toMap()).toList(),
      'rightEyePoints': rightEyePoints.map((p) => p.toMap()).toList(),
      'nosePoints': nosePoints.map((p) => p.toMap()).toList(),
      'mouthPoints': mouthPoints.map((p) => p.toMap()).toList(),
      'faceContourPoints': faceContourPoints.map((p) => p.toMap()).toList(),
      'leftEyebrowPoints': leftEyebrowPoints.map((p) => p.toMap()).toList(),
      'rightEyebrowPoints': rightEyebrowPoints.map((p) => p.toMap()).toList(),
    };
  }

  factory FacialLandmarks.fromMap(Map<String, dynamic> map) {
    return FacialLandmarks(
      leftEyePoints: (map['leftEyePoints'] as List)
          .map((p) => FacialPoint.fromMap(p))
          .toList(),
      rightEyePoints: (map['rightEyePoints'] as List)
          .map((p) => FacialPoint.fromMap(p))
          .toList(),
      nosePoints: (map['nosePoints'] as List)
          .map((p) => FacialPoint.fromMap(p))
          .toList(),
      mouthPoints: (map['mouthPoints'] as List)
          .map((p) => FacialPoint.fromMap(p))
          .toList(),
      faceContourPoints: (map['faceContourPoints'] as List)
          .map((p) => FacialPoint.fromMap(p))
          .toList(),
      leftEyebrowPoints: (map['leftEyebrowPoints'] as List)
          .map((p) => FacialPoint.fromMap(p))
          .toList(),
      rightEyebrowPoints: (map['rightEyebrowPoints'] as List)
          .map((p) => FacialPoint.fromMap(p))
          .toList(),
    );
  }

  factory FacialLandmarks.empty() {
    return FacialLandmarks(
      leftEyePoints: [],
      rightEyePoints: [],
      nosePoints: [],
      mouthPoints: [],
      faceContourPoints: [],
      leftEyebrowPoints: [],
      rightEyebrowPoints: [],
    );
  }
}

/// Individual facial measurement with uncertainty
class FacialMeasurement {
  final String metricId;
  final double value;
  final double uncertainty; // ± range in mm or degrees
  final double confidence; // 0.0 to 1.0
  final DateTime measuredAt;

  FacialMeasurement({
    required this.metricId,
    required this.value,
    required this.uncertainty,
    required this.confidence,
    DateTime? measuredAt,
  }) : measuredAt = measuredAt ?? DateTime.now();

  /// Display value with uncertainty (e.g., "63.2 ± 1.5 mm")
  String get displayValue {
    return '${value.toStringAsFixed(1)} ± ${uncertainty.toStringAsFixed(1)}';
  }

  /// Confidence as percentage string
  String get confidencePercent {
    return '${(confidence * 100).toStringAsFixed(0)}%';
  }

  Map<String, dynamic> toMap() {
    return {
      'metricId': metricId,
      'value': value,
      'uncertainty': uncertainty,
      'confidence': confidence,
      'measuredAt': measuredAt.toIso8601String(),
    };
  }

  factory FacialMeasurement.fromMap(Map<String, dynamic> map) {
    return FacialMeasurement(
      metricId: map['metricId'] as String,
      value: (map['value'] as num).toDouble(),
      uncertainty: (map['uncertainty'] as num).toDouble(),
      confidence: (map['confidence'] as num).toDouble(),
      measuredAt: DateTime.parse(map['measuredAt'] as String),
    );
  }
}

/// Face size validation result
class FaceSizeValidation {
  final bool passed;
  final double faceWidthRatio; // Face width / image width
  final double minRequired;
  final double maxAllowed;

  FaceSizeValidation({
    required this.passed,
    required this.faceWidthRatio,
    required this.minRequired,
    required this.maxAllowed,
  });

  String get message {
    if (passed) return 'Face size is good';
    if (faceWidthRatio < minRequired) {
      return 'Move closer to the camera';
    }
    if (faceWidthRatio > maxAllowed) {
      return 'Move further from the camera';
    }
    return 'Adjust your distance';
  }

  factory FaceSizeValidation.validate({
    required double faceWidth,
    required double imageWidth,
  }) {
    final ratio = faceWidth / imageWidth;
    return FaceSizeValidation(
      passed: ratio >= AppConstants.minFaceWidthRatio &&
          ratio <= AppConstants.maxFaceWidthRatio,
      faceWidthRatio: ratio,
      minRequired: AppConstants.minFaceWidthRatio,
      maxAllowed: AppConstants.maxFaceWidthRatio,
    );
  }
}

/// Pose (head angle) validation result
class PoseValidation {
  final bool passed;
  final double headEulerAngleX; // Pitch (up/down)
  final double headEulerAngleY; // Yaw (left/right)
  final double headEulerAngleZ; // Roll (tilt)
  final double maxAngleAllowed;

  PoseValidation({
    required this.passed,
    required this.headEulerAngleX,
    required this.headEulerAngleY,
    required this.headEulerAngleZ,
    required this.maxAngleAllowed,
  });

  String get message {
    if (passed) return 'Head position is good';
    if (headEulerAngleX.abs() > maxAngleAllowed) {
      return headEulerAngleX > 0 ? 'Tilt your head down' : 'Tilt your head up';
    }
    if (headEulerAngleY.abs() > maxAngleAllowed) {
      return headEulerAngleY > 0
          ? 'Turn your head left'
          : 'Turn your head right';
    }
    if (headEulerAngleZ.abs() > maxAngleAllowed) {
      return headEulerAngleZ > 0
          ? 'Tilt your head counter-clockwise'
          : 'Tilt your head clockwise';
    }
    return 'Face the camera directly';
  }

  factory PoseValidation.validate({
    required double pitch,
    required double yaw,
    required double roll,
  }) {
    final maxAngle = AppConstants.maxPoseAngleDegrees;
    return PoseValidation(
      passed: pitch.abs() <= maxAngle &&
          yaw.abs() <= maxAngle &&
          roll.abs() <= maxAngle,
      headEulerAngleX: pitch,
      headEulerAngleY: yaw,
      headEulerAngleZ: roll,
      maxAngleAllowed: maxAngle,
    );
  }
}

/// Lighting validation result
class LightingValidation {
  final bool passed;
  final double leftCheekBrightness;
  final double rightCheekBrightness;
  final double asymmetry; // Difference between sides (0.0 to 1.0)

  LightingValidation({
    required this.passed,
    required this.leftCheekBrightness,
    required this.rightCheekBrightness,
    required this.asymmetry,
  });

  String get message {
    if (passed) return 'Lighting is good';
    if (asymmetry > AppConstants.maxLightingAsymmetry) {
      if (leftCheekBrightness > rightCheekBrightness) {
        return 'Light is uneven - turn right slightly';
      } else {
        return 'Light is uneven - turn left slightly';
      }
    }
    return 'Find more even lighting';
  }

  factory LightingValidation.validate({
    required double leftBrightness,
    required double rightBrightness,
  }) {
    final maxBrightness =
        leftBrightness > rightBrightness ? leftBrightness : rightBrightness;
    final asymmetry = maxBrightness > 0
        ? (leftBrightness - rightBrightness).abs() / maxBrightness
        : 0.0;

    return LightingValidation(
      passed: asymmetry <= AppConstants.maxLightingAsymmetry,
      leftCheekBrightness: leftBrightness,
      rightCheekBrightness: rightBrightness,
      asymmetry: asymmetry,
    );
  }
}

/// Combined quality gate result
class QualityGateResult {
  final bool passed;
  final FaceSizeValidation faceSize;
  final PoseValidation pose;
  final LightingValidation lighting;
  final bool faceDetected;
  final List<String> failureReasons;

  QualityGateResult({
    required this.passed,
    required this.faceSize,
    required this.pose,
    required this.lighting,
    required this.faceDetected,
    required this.failureReasons,
  });

  /// Primary feedback message for user
  String get primaryMessage {
    if (passed) return 'Ready to analyze';
    if (!faceDetected) return 'No face detected';
    if (failureReasons.isNotEmpty) return failureReasons.first;
    return 'Adjust your position';
  }

  /// Create a failed result when no face is detected
  factory QualityGateResult.noFaceDetected() {
    return QualityGateResult(
      passed: false,
      faceSize: FaceSizeValidation(
        passed: false,
        faceWidthRatio: 0,
        minRequired: AppConstants.minFaceWidthRatio,
        maxAllowed: AppConstants.maxFaceWidthRatio,
      ),
      pose: PoseValidation(
        passed: false,
        headEulerAngleX: 0,
        headEulerAngleY: 0,
        headEulerAngleZ: 0,
        maxAngleAllowed: AppConstants.maxPoseAngleDegrees,
      ),
      lighting: LightingValidation(
        passed: false,
        leftCheekBrightness: 0,
        rightCheekBrightness: 0,
        asymmetry: 0,
      ),
      faceDetected: false,
      failureReasons: ['No face detected in frame'],
    );
  }

  /// Combine individual validations into overall result
  factory QualityGateResult.fromValidations({
    required FaceSizeValidation faceSize,
    required PoseValidation pose,
    required LightingValidation lighting,
  }) {
    final reasons = <String>[];
    if (!faceSize.passed) reasons.add(faceSize.message);
    if (!pose.passed) reasons.add(pose.message);
    if (!lighting.passed) reasons.add(lighting.message);

    return QualityGateResult(
      passed: faceSize.passed && pose.passed && lighting.passed,
      faceSize: faceSize,
      pose: pose,
      lighting: lighting,
      faceDetected: true,
      failureReasons: reasons,
    );
  }
}

/// Complete ML analysis result
class MLAnalysisResult {
  final FacialLandmarks landmarks;
  final Map<String, FacialMeasurement> measurements;
  final QualityGateResult qualityGate;
  final List<String> warnings;
  final int frameCount;
  final Duration processingTime;
  final DateTime analyzedAt;

  MLAnalysisResult({
    required this.landmarks,
    required this.measurements,
    required this.qualityGate,
    this.warnings = const [],
    required this.frameCount,
    required this.processingTime,
    DateTime? analyzedAt,
  }) : analyzedAt = analyzedAt ?? DateTime.now();

  /// Overall confidence (average of all measurements)
  double get overallConfidence {
    if (measurements.isEmpty) return 0.0;
    final sum =
        measurements.values.fold<double>(0, (sum, m) => sum + m.confidence);
    return sum / measurements.length;
  }

  /// Overall uncertainty (average across measurements)
  double get averageUncertainty {
    if (measurements.isEmpty) return 0.0;
    final sum =
        measurements.values.fold<double>(0, (sum, m) => sum + m.uncertainty);
    return sum / measurements.length;
  }

  Map<String, dynamic> toMap() {
    return {
      'landmarks': landmarks.toMap(),
      'measurements': measurements.map((k, v) => MapEntry(k, v.toMap())),
      'frameCount': frameCount,
      'processingTime': processingTime.inMilliseconds,
      'analyzedAt': analyzedAt.toIso8601String(),
    };
  }

  factory MLAnalysisResult.empty() {
    return MLAnalysisResult(
      landmarks: FacialLandmarks.empty(),
      measurements: {},
      qualityGate: QualityGateResult.noFaceDetected(),
      frameCount: 0,
      processingTime: Duration.zero,
    );
  }
}

/// Multi-frame analysis data for averaging
class MultiFrameData {
  final List<FacialLandmarks> frames;
  final List<double> pitchValues;
  final List<double> yawValues;
  final List<double> rollValues;

  const MultiFrameData({
    this.frames = const [],
    this.pitchValues = const [],
    this.yawValues = const [],
    this.rollValues = const [],
  });

  /// Number of frames captured
  int get frameCount => frames.length;

  /// Average landmarks across all frames (for stability)
  FacialLandmarks? get averagedLandmarks {
    if (frames.isEmpty) return null;
    if (frames.length == 1) return frames.first;

    // Average each point across frames
    return _averageLandmarks(frames);
  }

  /// Standard deviation of measurements (for uncertainty calculation)
  double calculateUncertainty(List<double> values) {
    if (values.length < 2) return 3.0; // Default high uncertainty
    final mean = values.reduce((a, b) => a + b) / values.length;
    final squaredDiffs =
        values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b);
    final variance = squaredDiffs / (values.length - 1);
    return variance.sqrt();
  }

  FacialLandmarks _averageLandmarks(List<FacialLandmarks> frames) {
    // Implementation would average each corresponding point
    // For simplicity, return the middle frame as best approximation
    return frames[frames.length ~/ 2];
  }

  MultiFrameData addFrame({
    required FacialLandmarks landmarks,
    required double pitch,
    required double yaw,
    required double roll,
  }) {
    return MultiFrameData(
      frames: [...frames, landmarks],
      pitchValues: [...pitchValues, pitch],
      yawValues: [...yawValues, yaw],
      rollValues: [...rollValues, roll],
    );
  }
}

/// Extension for sqrt on double
extension DoubleExtension on double {
  double sqrt() {
    if (this < 0) return 0;
    double guess = this / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + this / guess) / 2;
    }
    return guess;
  }
}
