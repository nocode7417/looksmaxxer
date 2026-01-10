/// Pose detection engine bridging ML Kit (Android) and Vision (iOS)
/// Processes body landmarks for rep counting with form validation

import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../data/models/workout_model.dart';

/// Body landmark enum matching ML Kit (33) and Vision (17) keypoints
enum BodyLandmark {
  // Head & Face
  nose,
  leftEye,
  rightEye,
  leftEar,
  rightEar,

  // Upper body
  leftShoulder,
  rightShoulder,
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,

  // Torso
  leftHip,
  rightHip,

  // Lower body
  leftKnee,
  rightKnee,
  leftAnkle,
  rightAnkle,
}

/// 2D point with confidence score
class Landmark {
  final double x; // Normalized 0-1
  final double y; // Normalized 0-1
  final double confidence; // 0-1

  const Landmark({
    required this.x,
    required this.y,
    required this.confidence,
  });

  /// Convert from screen coordinates
  factory Landmark.fromScreen({
    required double x,
    required double y,
    required double screenWidth,
    required double screenHeight,
    double confidence = 1.0,
  }) {
    return Landmark(
      x: x / screenWidth,
      y: y / screenHeight,
      confidence: confidence,
    );
  }

  /// Check if landmark is valid (high confidence and on screen)
  bool get isValid => confidence > 0.5 && x >= 0 && x <= 1 && y >= 0 && y <= 1;

  Map<String, dynamic> toMap() {
    return {'x': x, 'y': y, 'confidence': confidence};
  }

  factory Landmark.fromMap(Map<String, dynamic> map) {
    return Landmark(
      x: map['x'],
      y: map['y'],
      confidence: map['confidence'],
    );
  }
}

/// Pose data from single frame
class PoseData {
  final Map<BodyLandmark, Landmark> landmarks;
  final DateTime timestamp;
  final double overallConfidence;

  const PoseData({
    required this.landmarks,
    required this.timestamp,
    required this.overallConfidence,
  });

  /// Get landmark safely with null check
  Landmark? getLandmark(BodyLandmark type) => landmarks[type];

  /// Calculate angle between three points (in degrees)
  /// Used for elbow angles, knee angles, etc.
  double? calculateAngle(
    BodyLandmark pointA,
    BodyLandmark pointB,
    BodyLandmark pointC,
  ) {
    final a = getLandmark(pointA);
    final b = getLandmark(pointB);
    final c = getLandmark(pointC);

    if (a == null || b == null || c == null) return null;
    if (!a.isValid || !b.isValid || !c.isValid) return null;

    // Calculate vectors
    final ba = math.Point(a.x - b.x, a.y - b.y);
    final bc = math.Point(c.x - b.x, c.y - b.y);

    // Calculate angle using dot product
    final dot = ba.x * bc.x + ba.y * bc.y;
    final magBA = math.sqrt(ba.x * ba.x + ba.y * ba.y);
    final magBC = math.sqrt(bc.x * bc.x + bc.y * bc.y);

    if (magBA == 0 || magBC == 0) return null;

    final cosAngle = dot / (magBA * magBC);
    final angleRad = math.acos(cosAngle.clamp(-1.0, 1.0));
    return angleRad * 180 / math.pi;
  }

  /// Calculate distance between two landmarks (normalized)
  double? calculateDistance(BodyLandmark pointA, BodyLandmark pointB) {
    final a = getLandmark(pointA);
    final b = getLandmark(pointB);

    if (a == null || b == null) return null;
    if (!a.isValid || !b.isValid) return null;

    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  /// Calculate horizontal distance (for chin tucks - ear to shoulder)
  double? calculateHorizontalDistance(
      BodyLandmark pointA, BodyLandmark pointB) {
    final a = getLandmark(pointA);
    final b = getLandmark(pointB);

    if (a == null || b == null) return null;
    if (!a.isValid || !b.isValid) return null;

    return (a.x - b.x).abs();
  }

  /// Calculate vertical alignment (for posture checks)
  double? calculateVerticalAlignment(
      BodyLandmark pointA, BodyLandmark pointB) {
    final a = getLandmark(pointA);
    final b = getLandmark(pointB);

    if (a == null || b == null) return null;
    if (!a.isValid || !b.isValid) return null;

    // Return horizontal offset (should be near 0 for vertical alignment)
    return (a.x - b.x).abs();
  }

  Map<String, dynamic> toMap() {
    return {
      'landmarks':
          landmarks.map((k, v) => MapEntry(k.name, v.toMap())),
      'timestamp': timestamp.toIso8601String(),
      'overallConfidence': overallConfidence,
    };
  }
}

/// Rep detector result
class RepDetectionResult {
  final bool isRep;
  final double formAccuracy; // 0-1
  final String? feedback; // What went wrong
  final Map<String, double>? metrics; // Angles, distances for analysis

  const RepDetectionResult({
    required this.isRep,
    required this.formAccuracy,
    this.feedback,
    this.metrics,
  });

  bool get isValidRep => isRep && formAccuracy >= 0.60; // Minimum threshold
}

/// State machine for rep detection
enum RepState {
  idle,          // Not started
  starting,      // Beginning movement
  inProgress,    // Mid-rep
  holding,       // Isometric hold
  completing,    // Finishing movement
  completed,     // Rep done
}

/// Base class for workout-specific rep detectors
abstract class RepDetector {
  RepState _state = RepState.idle;
  DateTime? _repStartTime;
  DateTime? _holdStartTime;
  final List<PoseData> _frameBuffer = [];
  static const int bufferSize = 10; // Analyze last 10 frames

  RepState get state => _state;

  /// Process new pose data and detect reps
  RepDetectionResult process(PoseData pose);

  /// Reset detector for new rep
  void reset() {
    _state = RepState.idle;
    _repStartTime = null;
    _holdStartTime = null;
    _frameBuffer.clear();
  }

  /// Add frame to buffer for smoothing
  void _addFrame(PoseData pose) {
    _frameBuffer.add(pose);
    if (_frameBuffer.length > bufferSize) {
      _frameBuffer.removeAt(0);
    }
  }

  /// Calculate average metric over buffered frames
  double _averageMetric(double? Function(PoseData) calculator) {
    final values =
        _frameBuffer.map(calculator).whereType<double>().toList();
    if (values.isEmpty) return 0.0;
    return values.reduce((a, b) => a + b) / values.length;
  }
}

/// Chin tuck rep detector
class ChinTuckDetector extends RepDetector {
  final int targetHoldSeconds;
  double? _baselineDistance; // Starting ear-shoulder distance

  ChinTuckDetector({required this.targetHoldSeconds});

  @override
  RepDetectionResult process(PoseData pose) {
    _addFrame(pose);

    // Calculate ear-shoulder horizontal distance
    final earToShoulder = pose.calculateHorizontalDistance(
      BodyLandmark.leftEar,
      BodyLandmark.leftShoulder,
    );

    if (earToShoulder == null) {
      return RepDetectionResult(
        isRep: false,
        formAccuracy: 0.0,
        feedback: 'Cannot detect head position',
      );
    }

    // Calculate vertical alignment (ear should be over shoulder)
    final verticalAlignment = pose.calculateVerticalAlignment(
      BodyLandmark.leftEar,
      BodyLandmark.leftShoulder,
    );

    switch (_state) {
      case RepState.idle:
        // Establish baseline
        _baselineDistance = earToShoulder;
        _state = RepState.starting;
        return RepDetectionResult(
          isRep: false,
          formAccuracy: 1.0,
        );

      case RepState.starting:
        // Check if head is moving back
        if (_baselineDistance != null &&
            earToShoulder < _baselineDistance! * 0.8) {
          // Moved back 20% from baseline
          _state = RepState.inProgress;
        }
        return RepDetectionResult(
          isRep: false,
          formAccuracy: 1.0,
        );

      case RepState.inProgress:
        // Check if reached target position (ear aligned over shoulder)
        if (verticalAlignment != null && verticalAlignment < 0.05) {
          // Within 5% alignment
          _state = RepState.holding;
          _holdStartTime = DateTime.now();
        }
        return RepDetectionResult(
          isRep: false,
          formAccuracy: 0.8,
        );

      case RepState.holding:
        // Count hold duration
        if (_holdStartTime != null) {
          final holdDuration =
              DateTime.now().difference(_holdStartTime!).inSeconds;
          if (holdDuration >= targetHoldSeconds) {
            _state = RepState.completing;
          }
        }
        return RepDetectionResult(
          isRep: false,
          formAccuracy: 0.9,
          feedback: 'Hold position...',
        );

      case RepState.completing:
        // Check if returned to start
        if (_baselineDistance != null &&
            earToShoulder >= _baselineDistance! * 0.95) {
          _state = RepState.completed;
          final formScore = _calculateFormScore(pose, verticalAlignment);
          reset();
          return RepDetectionResult(
            isRep: true,
            formAccuracy: formScore,
            metrics: {
              'earToShoulder': earToShoulder,
              'verticalAlignment': verticalAlignment ?? 0.0,
            },
          );
        }
        return RepDetectionResult(
          isRep: false,
          formAccuracy: 0.9,
        );

      case RepState.completed:
        reset();
        return RepDetectionResult(
          isRep: false,
          formAccuracy: 1.0,
        );
    }
  }

  double _calculateFormScore(PoseData pose, double? verticalAlignment) {
    double score = 1.0;

    // Penalize poor vertical alignment
    if (verticalAlignment != null && verticalAlignment > 0.05) {
      score -= 0.2;
    }

    // Check for head tilting (nose should stay level with eyes)
    final noseY = pose.getLandmark(BodyLandmark.nose)?.y;
    final leftEyeY = pose.getLandmark(BodyLandmark.leftEye)?.y;
    if (noseY != null && leftEyeY != null) {
      final tilt = (noseY - leftEyeY).abs();
      if (tilt > 0.03) score -= 0.2; // Head tilted
    }

    return score.clamp(0.0, 1.0);
  }
}

/// Push-up rep detector
class PushUpDetector extends RepDetector {
  static const double downAngle = 90.0; // Elbow angle at bottom
  static const double upAngle = 160.0; // Elbow angle at top
  bool _isDown = false;

  @override
  RepDetectionResult process(PoseData pose) {
    _addFrame(pose);

    // Calculate elbow angle
    final elbowAngle = pose.calculateAngle(
      BodyLandmark.leftShoulder,
      BodyLandmark.leftElbow,
      BodyLandmark.leftWrist,
    );

    if (elbowAngle == null) {
      return RepDetectionResult(
        isRep: false,
        formAccuracy: 0.0,
        feedback: 'Cannot detect arm position',
      );
    }

    // Check body alignment (shoulder-hip-knee should be straight)
    final shoulderY = pose.getLandmark(BodyLandmark.leftShoulder)?.y;
    final hipY = pose.getLandmark(BodyLandmark.leftHip)?.y;
    final kneeY = pose.getLandmark(BodyLandmark.leftKnee)?.y;

    double formScore = 1.0;
    String? feedback;

    // Check for sagging hips
    if (shoulderY != null && hipY != null && kneeY != null) {
      final shoulderToHip = hipY - shoulderY;
      final hipToKnee = kneeY - hipY;
      final ratio = shoulderToHip / hipToKnee;

      if (ratio < 0.8 || ratio > 1.2) {
        // Body not straight
        formScore -= 0.3;
        feedback = 'Keep body straight';
      }
    }

    // State machine for rep detection
    if (elbowAngle >= upAngle && _isDown) {
      // Completed a rep (returned to up position)
      _isDown = false;
      reset();
      return RepDetectionResult(
        isRep: true,
        formAccuracy: formScore,
        feedback: feedback,
        metrics: {
          'elbowAngle': elbowAngle,
        },
      );
    } else if (elbowAngle <= downAngle && !_isDown) {
      // Went down
      _isDown = true;
      return RepDetectionResult(
        isRep: false,
        formAccuracy: formScore,
        feedback: feedback,
      );
    }

    return RepDetectionResult(
      isRep: false,
      formAccuracy: formScore,
      feedback: feedback,
    );
  }
}

/// Face pull rep detector
class FacePullDetector extends RepDetector {
  DateTime? _lastRepTime;
  static const int minRepDurationMs = 2000; // Must take at least 2 seconds
  bool _isPulled = false;

  @override
  RepDetectionResult process(PoseData pose) {
    _addFrame(pose);

    // Calculate wrist height relative to shoulders
    final wristY = pose.getLandmark(BodyLandmark.leftWrist)?.y;
    final shoulderY = pose.getLandmark(BodyLandmark.leftShoulder)?.y;

    if (wristY == null || shoulderY == null) {
      return RepDetectionResult(
        isRep: false,
        formAccuracy: 0.0,
        feedback: 'Cannot detect arm position',
      );
    }

    // Check if hands are at face level (wrists above shoulders)
    final isAtFaceLevel = wristY < shoulderY;

    // Check rep tempo
    if (_lastRepTime != null) {
      final timeSinceLastRep = DateTime.now().difference(_lastRepTime!);
      if (timeSinceLastRep.inMilliseconds < minRepDurationMs) {
        return RepDetectionResult(
          isRep: false,
          formAccuracy: 0.5,
          feedback: 'Slow down - controlled movement',
        );
      }
    }

    // State machine
    if (isAtFaceLevel && !_isPulled) {
      _isPulled = true;
      _repStartTime = DateTime.now();
      return RepDetectionResult(
        isRep: false,
        formAccuracy: 0.9,
        feedback: 'Squeeze shoulder blades',
      );
    } else if (!isAtFaceLevel && _isPulled) {
      // Completed rep
      _isPulled = false;
      _lastRepTime = DateTime.now();

      // Check if rep was slow enough
      if (_repStartTime != null) {
        final repDuration = _lastRepTime!.difference(_repStartTime!);
        if (repDuration.inMilliseconds < minRepDurationMs) {
          return RepDetectionResult(
            isRep: false,
            formAccuracy: 0.6,
            feedback: 'Too fast! Control the movement',
          );
        }
      }

      reset();
      return RepDetectionResult(
        isRep: true,
        formAccuracy: 1.0,
        metrics: {
          'wristHeight': wristY,
        },
      );
    }

    return RepDetectionResult(
      isRep: false,
      formAccuracy: 0.8,
    );
  }
}

/// Neck curl rep detector
class NeckCurlDetector extends RepDetector {
  DateTime? _lastRepTime;
  static const int minRepDurationMs = 1500; // Must take at least 1.5 seconds
  bool _isCurled = false;

  @override
  RepDetectionResult process(PoseData pose) {
    _addFrame(pose);

    // Calculate head angle (nose relative to ears)
    final noseY = pose.getLandmark(BodyLandmark.nose)?.y;
    final earY = pose.getLandmark(BodyLandmark.leftEar)?.y;

    if (noseY == null || earY == null) {
      return RepDetectionResult(
        isRep: false,
        formAccuracy: 0.0,
        feedback: 'Cannot detect head position',
      );
    }

    // Check if chin is curled to chest (nose below ears)
    final isCurled = noseY > earY + 0.05; // Nose significantly below ear

    // CRITICAL SAFETY CHECK - movement speed
    if (_lastRepTime != null) {
      final timeSinceLastRep = DateTime.now().difference(_lastRepTime!);
      if (timeSinceLastRep.inMilliseconds < minRepDurationMs) {
        return RepDetectionResult(
          isRep: false,
          formAccuracy: 0.3,
          feedback: '⚠️ TOO FAST - Risk of injury!',
        );
      }
    }

    // State machine
    if (isCurled && !_isCurled) {
      _isCurled = true;
      _repStartTime = DateTime.now();
      return RepDetectionResult(
        isRep: false,
        formAccuracy: 0.9,
        feedback: 'Hold briefly',
      );
    } else if (!isCurled && _isCurled) {
      // Completed rep
      _isCurled = false;
      _lastRepTime = DateTime.now();

      // Check if rep was slow enough (SAFETY)
      if (_repStartTime != null) {
        final repDuration = _lastRepTime!.difference(_repStartTime!);
        if (repDuration.inMilliseconds < minRepDurationMs) {
          return RepDetectionResult(
            isRep: false,
            formAccuracy: 0.4,
            feedback: '⚠️ Too fast! High injury risk',
          );
        }
      }

      reset();
      return RepDetectionResult(
        isRep: true,
        formAccuracy: 1.0,
        metrics: {
          'headAngle': noseY - earY,
        },
      );
    }

    return RepDetectionResult(
      isRep: false,
      formAccuracy: 0.8,
    );
  }
}

/// Factory for creating workout-specific detectors
class RepDetectorFactory {
  static RepDetector create(WorkoutType type, WorkoutConfig config) {
    switch (type) {
      case WorkoutType.chinTucks:
        return ChinTuckDetector(
          targetHoldSeconds: config.holdDurationSeconds,
        );
      case WorkoutType.pushUps:
        return PushUpDetector();
      case WorkoutType.facePulls:
        return FacePullDetector();
      case WorkoutType.neckCurls:
        return NeckCurlDetector();
    }
  }
}
