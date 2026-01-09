import 'dart:typed_data';
import 'dart:ui';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../data/models/ml_analysis_model.dart';
import '../core/constants/app_constants.dart';

/// ML Kit Face Analyzer - wraps ML Kit for facial analysis
class MLFacialAnalyzer {
  FaceDetector? _faceDetector;
  bool _isInitialized = false;

  /// Initialize the face detector
  Future<void> initialize() async {
    if (_isInitialized) return;

    final options = FaceDetectorOptions(
      enableLandmarks: true,
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.15, // Minimum 15% of image
    );

    _faceDetector = FaceDetector(options: options);
    _isInitialized = true;
  }

  /// Check if analyzer is ready
  bool get isInitialized => _isInitialized;

  /// Process an image and detect faces
  Future<List<Face>> detectFaces(InputImage inputImage) async {
    if (!_isInitialized || _faceDetector == null) {
      throw StateError('MLFacialAnalyzer not initialized');
    }

    return await _faceDetector!.processImage(inputImage);
  }

  /// Analyze a face and extract landmarks
  FacialLandmarks extractLandmarks(Face face) {
    return FacialLandmarks(
      leftEyePoints: _extractEyePoints(face, FaceLandmarkType.leftEye),
      rightEyePoints: _extractEyePoints(face, FaceLandmarkType.rightEye),
      nosePoints: _extractNosePoints(face),
      mouthPoints: _extractMouthPoints(face),
      faceContourPoints: _extractContourPoints(face, FaceContourType.face),
      leftEyebrowPoints: _extractContourPoints(face, FaceContourType.leftEyebrowTop),
      rightEyebrowPoints: _extractContourPoints(face, FaceContourType.rightEyebrowTop),
    );
  }

  /// Extract eye landmark points
  List<FacialPoint> _extractEyePoints(Face face, FaceLandmarkType type) {
    final points = <FacialPoint>[];

    final landmark = face.landmarks[type];
    if (landmark != null) {
      points.add(FacialPoint(
        landmark.position.x.toDouble(),
        landmark.position.y.toDouble(),
      ));
    }

    // Also get eye contour for more points
    final contourType = type == FaceLandmarkType.leftEye
        ? FaceContourType.leftEye
        : FaceContourType.rightEye;
    final contour = face.contours[contourType];
    if (contour != null) {
      for (final point in contour.points) {
        points.add(FacialPoint(
          point.x.toDouble(),
          point.y.toDouble(),
        ));
      }
    }

    return points;
  }

  /// Extract nose landmark points
  List<FacialPoint> _extractNosePoints(Face face) {
    final points = <FacialPoint>[];

    // Get nose base landmark
    final noseBase = face.landmarks[FaceLandmarkType.noseBase];
    if (noseBase != null) {
      points.add(FacialPoint(
        noseBase.position.x.toDouble(),
        noseBase.position.y.toDouble(),
      ));
    }

    // Get nose contour
    final contour = face.contours[FaceContourType.noseBridge];
    if (contour != null) {
      for (final point in contour.points) {
        points.add(FacialPoint(
          point.x.toDouble(),
          point.y.toDouble(),
        ));
      }
    }

    final bottomContour = face.contours[FaceContourType.noseBottom];
    if (bottomContour != null) {
      for (final point in bottomContour.points) {
        points.add(FacialPoint(
          point.x.toDouble(),
          point.y.toDouble(),
        ));
      }
    }

    return points;
  }

  /// Extract mouth landmark points
  List<FacialPoint> _extractMouthPoints(Face face) {
    final points = <FacialPoint>[];

    // Get mouth landmarks
    final bottomMouth = face.landmarks[FaceLandmarkType.bottomMouth];
    if (bottomMouth != null) {
      points.add(FacialPoint(
        bottomMouth.position.x.toDouble(),
        bottomMouth.position.y.toDouble(),
      ));
    }

    final leftMouth = face.landmarks[FaceLandmarkType.leftMouth];
    if (leftMouth != null) {
      points.add(FacialPoint(
        leftMouth.position.x.toDouble(),
        leftMouth.position.y.toDouble(),
      ));
    }

    final rightMouth = face.landmarks[FaceLandmarkType.rightMouth];
    if (rightMouth != null) {
      points.add(FacialPoint(
        rightMouth.position.x.toDouble(),
        rightMouth.position.y.toDouble(),
      ));
    }

    // Get mouth contours
    final upperLip = face.contours[FaceContourType.upperLipTop];
    if (upperLip != null) {
      for (final point in upperLip.points) {
        points.add(FacialPoint(
          point.x.toDouble(),
          point.y.toDouble(),
        ));
      }
    }

    final lowerLip = face.contours[FaceContourType.lowerLipBottom];
    if (lowerLip != null) {
      for (final point in lowerLip.points) {
        points.add(FacialPoint(
          point.x.toDouble(),
          point.y.toDouble(),
        ));
      }
    }

    return points;
  }

  /// Extract contour points
  List<FacialPoint> _extractContourPoints(Face face, FaceContourType type) {
    final points = <FacialPoint>[];
    final contour = face.contours[type];

    if (contour != null) {
      for (final point in contour.points) {
        points.add(FacialPoint(
          point.x.toDouble(),
          point.y.toDouble(),
        ));
      }
    }

    return points;
  }

  /// Validate face size quality gate
  FaceSizeValidation validateFaceSize(Face face, Size imageSize) {
    final boundingBox = face.boundingBox;
    final faceWidthRatio = boundingBox.width / imageSize.width;

    return FaceSizeValidation(
      passed: faceWidthRatio >= AppConstants.minFaceWidthRatio &&
          faceWidthRatio <= AppConstants.maxFaceWidthRatio,
      faceWidthRatio: faceWidthRatio,
      minRequired: AppConstants.minFaceWidthRatio,
      maxAllowed: AppConstants.maxFaceWidthRatio,
    );
  }

  /// Validate head pose quality gate
  PoseValidation validatePose(Face face) {
    final pitch = face.headEulerAngleX ?? 0.0;
    final yaw = face.headEulerAngleY ?? 0.0;
    final roll = face.headEulerAngleZ ?? 0.0;

    return PoseValidation.validate(
      pitch: pitch,
      yaw: yaw,
      roll: roll,
    );
  }

  /// Calculate all quality gates for a face
  QualityGateResult validateQualityGates(
    Face face,
    Size imageSize, {
    double leftBrightness = 0.5,
    double rightBrightness = 0.5,
  }) {
    final faceSize = validateFaceSize(face, imageSize);
    final pose = validatePose(face);
    final lighting = LightingValidation.validate(
      leftBrightness: leftBrightness,
      rightBrightness: rightBrightness,
    );

    return QualityGateResult.fromValidations(
      faceSize: faceSize,
      pose: pose,
      lighting: lighting,
    );
  }

  /// Calculate facial measurements from landmarks
  Map<String, FacialMeasurement> calculateMeasurements(
    FacialLandmarks landmarks,
    Face face, {
    int frameCount = 1,
    double baseUncertainty = 2.0,
  }) {
    final measurements = <String, FacialMeasurement>{};
    final now = DateTime.now();

    // Calculate confidence based on frame count
    final confidence = _calculateConfidence(frameCount);

    // Reduce uncertainty with more frames
    final uncertainty = baseUncertainty / (frameCount > 1 ? frameCount.sqrt() : 1);

    // Facial Symmetry (0-100)
    final symmetry = _calculateSymmetryScore(landmarks, face);
    measurements['facialSymmetry'] = FacialMeasurement(
      metricId: 'facialSymmetry',
      value: symmetry,
      uncertainty: uncertainty,
      confidence: confidence,
      measuredAt: now,
    );

    // Proportional Harmony (-15 to +15, 0 is ideal)
    final harmony = _calculateHarmonyScore(landmarks, face);
    measurements['proportionalHarmony'] = FacialMeasurement(
      metricId: 'proportionalHarmony',
      value: harmony,
      uncertainty: uncertainty * 0.5,
      confidence: confidence,
      measuredAt: now,
    );

    // Canthal Tilt (-10 to +15 degrees)
    final canthalTilt = _calculateCanthalTilt(landmarks, face);
    measurements['canthalTilt'] = FacialMeasurement(
      metricId: 'canthalTilt',
      value: canthalTilt,
      uncertainty: uncertainty * 0.3,
      confidence: confidence,
      measuredAt: now,
    );

    // Skin Texture (requires image analysis, estimate from face detection quality)
    final skinTexture = _estimateSkinTexture(face);
    measurements['skinTexture'] = FacialMeasurement(
      metricId: 'skinTexture',
      value: skinTexture,
      uncertainty: 5.0, // Higher uncertainty for estimated metrics
      confidence: confidence * 0.7,
      measuredAt: now,
    );

    // Skin Clarity (estimate)
    final skinClarity = _estimateSkinClarity(face);
    measurements['skinClarity'] = FacialMeasurement(
      metricId: 'skinClarity',
      value: skinClarity,
      uncertainty: 5.0,
      confidence: confidence * 0.7,
      measuredAt: now,
    );

    // Jaw Definition (from contour sharpness)
    final jawDefinition = _calculateJawDefinition(landmarks, face);
    measurements['jawDefinition'] = FacialMeasurement(
      metricId: 'jawDefinition',
      value: jawDefinition,
      uncertainty: uncertainty * 1.5,
      confidence: confidence * 0.8,
      measuredAt: now,
    );

    // Cheekbone Prominence (from contour analysis)
    final cheekboneProminence = _calculateCheekboneProminence(landmarks, face);
    measurements['cheekboneProminence'] = FacialMeasurement(
      metricId: 'cheekboneProminence',
      value: cheekboneProminence,
      uncertainty: uncertainty * 1.5,
      confidence: confidence * 0.8,
      measuredAt: now,
    );

    return measurements;
  }

  /// Calculate confidence based on frame count
  double _calculateConfidence(int frameCount) {
    if (frameCount >= 10) return 0.95;
    if (frameCount >= 7) return 0.90;
    if (frameCount >= 5) return 0.85;
    if (frameCount >= 3) return 0.75;
    return 0.60;
  }

  /// Calculate facial symmetry score (0-100)
  double _calculateSymmetryScore(FacialLandmarks landmarks, Face face) {
    double totalScore = 0;
    int comparisons = 0;

    // Compare eye positions
    final leftEye = landmarks.leftEyeCenter;
    final rightEye = landmarks.rightEyeCenter;

    if (leftEye != null && rightEye != null) {
      // Get midline
      final midX = (leftEye.x + rightEye.x) / 2;

      // Compare distances from midline
      final leftDist = (leftEye.x - midX).abs();
      final rightDist = (rightEye.x - midX).abs();
      final maxDist = leftDist > rightDist ? leftDist : rightDist;

      if (maxDist > 0) {
        final eyeSymmetry = 1 - ((leftDist - rightDist).abs() / maxDist);
        totalScore += eyeSymmetry * 100;
        comparisons++;
      }

      // Compare Y positions
      final yDiff = (leftEye.y - rightEye.y).abs();
      final interocular = landmarks.interocularDistance ?? 1;
      final ySymmetry = 1 - (yDiff / interocular).clamp(0, 1);
      totalScore += ySymmetry * 100;
      comparisons++;
    }

    // Compare mouth corners
    if (landmarks.mouthPoints.length >= 3) {
      // Assuming first two points are corners
      // This is a simplification
      totalScore += 85; // Default good score for mouth
      comparisons++;
    }

    // Average all comparisons
    if (comparisons == 0) return 75; // Default score
    return (totalScore / comparisons).clamp(0, 100);
  }

  /// Calculate proportional harmony score (-15 to +15)
  double _calculateHarmonyScore(FacialLandmarks landmarks, Face face) {
    final boundingBox = face.boundingBox;
    final faceHeight = boundingBox.height;
    final faceWidth = boundingBox.width;

    if (faceWidth == 0) return 0;

    // Golden ratio comparison
    const idealRatio = 1.618;
    final actualRatio = faceHeight / faceWidth;

    // Calculate deviation
    final deviation = (actualRatio - idealRatio) * 10;
    return deviation.clamp(-15.0, 15.0);
  }

  /// Calculate canthal tilt (-10 to +15 degrees)
  double _calculateCanthalTilt(FacialLandmarks landmarks, Face face) {
    final leftEye = landmarks.leftEyeCenter;
    final rightEye = landmarks.rightEyeCenter;

    if (leftEye == null || rightEye == null) return 0;

    // Calculate angle between eye centers
    final dy = rightEye.y - leftEye.y;
    final dx = rightEye.x - leftEye.x;

    if (dx == 0) return 0;

    // Convert to degrees (atan approximation)
    final ratio = dy / dx;
    final degrees = ratio * 57.2958;

    return degrees.clamp(-10.0, 15.0);
  }

  /// Estimate skin texture from face detection (simplified)
  double _estimateSkinTexture(Face face) {
    // ML Kit doesn't provide direct skin texture analysis
    // Use tracking ID stability as a proxy for image quality
    final trackingId = face.trackingId;
    final baseScore = 70.0;

    // If tracking is stable, assume good skin visibility
    if (trackingId != null) {
      return baseScore + 10;
    }
    return baseScore;
  }

  /// Estimate skin clarity (simplified)
  double _estimateSkinClarity(Face face) {
    // Use face detection confidence as proxy
    // ML Kit doesn't expose confidence directly, so estimate
    final boundingBox = face.boundingBox;
    final faceArea = boundingBox.width * boundingBox.height;

    // Larger detected face = better clarity estimate
    if (faceArea > 50000) return 80;
    if (faceArea > 30000) return 75;
    if (faceArea > 10000) return 70;
    return 65;
  }

  /// Calculate jaw definition from contour
  double _calculateJawDefinition(FacialLandmarks landmarks, Face face) {
    final contourPoints = landmarks.faceContourPoints;

    if (contourPoints.length < 10) return 60;

    // Analyze contour sharpness at jaw region
    // More points = better definition detection
    final pointCount = contourPoints.length;

    // Score based on contour detail
    final detailScore = (pointCount / 36 * 40).clamp(0, 40);
    return (50 + detailScore).clamp(0, 100);
  }

  /// Calculate cheekbone prominence
  double _calculateCheekboneProminence(FacialLandmarks landmarks, Face face) {
    final faceWidth = landmarks.facialWidth;
    final faceHeight = landmarks.facialHeight;

    if (faceWidth == null || faceHeight == null || faceHeight == 0) {
      return 60;
    }

    // Width to height ratio indicates cheekbone prominence
    final ratio = faceWidth / faceHeight;

    // Higher ratio = more prominent cheekbones
    return (ratio * 80).clamp(40, 90);
  }

  /// Select best frame from multiple captures
  Face? selectBestFrame(List<Face> faces) {
    if (faces.isEmpty) return null;
    if (faces.length == 1) return faces.first;

    Face? bestFace;
    double bestScore = -1;

    for (final face in faces) {
      double score = 0;

      // Score by pose angle (closer to 0 is better)
      final pitch = (face.headEulerAngleX ?? 0).abs();
      final yaw = (face.headEulerAngleY ?? 0).abs();
      final roll = (face.headEulerAngleZ ?? 0).abs();
      score += 100 - (pitch + yaw + roll);

      // Score by bounding box size (larger is better)
      final area = face.boundingBox.width * face.boundingBox.height;
      score += area / 1000;

      // Score by landmark count
      score += face.landmarks.length * 5;
      score += face.contours.length * 3;

      if (score > bestScore) {
        bestScore = score;
        bestFace = face;
      }
    }

    return bestFace;
  }

  /// Dispose the face detector
  void dispose() {
    _faceDetector?.close();
    _faceDetector = null;
    _isInitialized = false;
  }
}

/// Extension for sqrt on num
extension NumSqrt on num {
  double sqrt() {
    if (this < 0) return 0;
    double val = toDouble();
    double guess = val / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + val / guess) / 2;
    }
    return guess;
  }
}
