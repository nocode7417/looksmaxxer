import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../data/models/photo_model.dart';
import '../data/models/ml_analysis_model.dart';
import '../core/constants/app_constants.dart';

/// Quality validation for captured photos
/// Includes both image quality and face-specific quality gates
class QualityValidator {
  /// Analyze image quality
  static Future<QualityScore> analyzeQuality(Uint8List imageData) async {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) {
        return QualityScore(
          brightness: 0,
          contrast: 0,
          sharpness: 0,
          overall: 0,
        );
      }

      final brightness = _analyzeBrightness(image);
      final contrast = _analyzeContrast(image);
      final sharpness = _analyzeSharpness(image);

      // Weighted average: brightness 30%, contrast 30%, sharpness 40%
      final overall = brightness * 0.3 + contrast * 0.3 + sharpness * 0.4;

      return QualityScore(
        brightness: brightness,
        contrast: contrast,
        sharpness: sharpness,
        overall: overall,
      );
    } catch (e) {
      return QualityScore(
        brightness: 50,
        contrast: 50,
        sharpness: 50,
        overall: 50,
      );
    }
  }

  /// Analyze brightness (0-100)
  static double _analyzeBrightness(img.Image image) {
    double totalBrightness = 0;
    int pixelCount = 0;

    // Sample pixels for performance
    final step = max(1, (image.width * image.height) ~/ 10000);

    for (int y = 0; y < image.height; y += step) {
      for (int x = 0; x < image.width; x += step) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        // Calculate perceived brightness
        final brightness = (0.299 * r + 0.587 * g + 0.114 * b);
        totalBrightness += brightness;
        pixelCount++;
      }
    }

    final avgBrightness = totalBrightness / pixelCount;

    // Map to 0-100 score based on optimal range (40-120)
    if (avgBrightness < AppConstants.optimalBrightnessMin) {
      return (avgBrightness / AppConstants.optimalBrightnessMin) * 50;
    } else if (avgBrightness > AppConstants.optimalBrightnessMax) {
      final excess = avgBrightness - AppConstants.optimalBrightnessMax;
      return max(0, 100 - (excess / 135) * 50);
    } else {
      // In optimal range
      return 70 + ((avgBrightness - AppConstants.optimalBrightnessMin) /
              (AppConstants.optimalBrightnessMax -
                  AppConstants.optimalBrightnessMin)) *
          30;
    }
  }

  /// Analyze contrast using standard deviation (0-100)
  static double _analyzeContrast(img.Image image) {
    final luminanceValues = <double>[];
    final step = max(1, (image.width * image.height) ~/ 10000);

    for (int y = 0; y < image.height; y += step) {
      for (int x = 0; x < image.width; x += step) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        final luminance = 0.299 * r + 0.587 * g + 0.114 * b;
        luminanceValues.add(luminance);
      }
    }

    if (luminanceValues.isEmpty) return 50;

    // Calculate standard deviation
    final mean =
        luminanceValues.reduce((a, b) => a + b) / luminanceValues.length;
    final squaredDiffs =
        luminanceValues.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b);
    final stdDev = sqrt(squaredDiffs / luminanceValues.length);

    // Map stdDev to 0-100 score (optimal stdDev around 50-70)
    if (stdDev < 20) {
      return stdDev * 2; // Low contrast
    } else if (stdDev > 80) {
      return max(50, 100 - (stdDev - 80)); // High contrast
    } else {
      return 60 + ((stdDev - 20) / 60) * 40; // Good contrast range
    }
  }

  /// Analyze sharpness using edge detection (0-100)
  static double _analyzeSharpness(img.Image image) {
    // Simplified Laplacian-based edge detection
    double edgeSum = 0;
    int edgeCount = 0;

    final step = max(2, (image.width * image.height) ~/ 5000);

    for (int y = 1; y < image.height - 1; y += step) {
      for (int x = 1; x < image.width - 1; x += step) {
        // Get surrounding pixels for Laplacian
        final center = _getLuminance(image, x, y);
        final top = _getLuminance(image, x, y - 1);
        final bottom = _getLuminance(image, x, y + 1);
        final left = _getLuminance(image, x - 1, y);
        final right = _getLuminance(image, x + 1, y);

        // Laplacian = 4*center - top - bottom - left - right
        final laplacian = (4 * center - top - bottom - left - right).abs();
        edgeSum += laplacian;
        edgeCount++;
      }
    }

    if (edgeCount == 0) return 50;

    final avgEdge = edgeSum / edgeCount;

    // Map edge strength to 0-100 score
    // Higher edge values indicate sharper image
    return min(100, avgEdge * 2);
  }

  static double _getLuminance(img.Image image, int x, int y) {
    final pixel = image.getPixel(x, y);
    return 0.299 * pixel.r.toInt() +
        0.587 * pixel.g.toInt() +
        0.114 * pixel.b.toInt();
  }

  /// Get quality feedback messages
  static List<QualityFeedback> getQualityFeedback(QualityScore score) {
    final feedback = <QualityFeedback>[];

    if (score.brightness < 50) {
      feedback.add(QualityFeedback(
        type: QualityFeedbackType.warning,
        message: 'Image is too dark. Try better lighting.',
      ));
    } else if (score.brightness > 90) {
      feedback.add(QualityFeedback(
        type: QualityFeedbackType.warning,
        message: 'Image is overexposed. Reduce lighting.',
      ));
    }

    if (score.contrast < 40) {
      feedback.add(QualityFeedback(
        type: QualityFeedbackType.warning,
        message: 'Low contrast. Ensure even lighting.',
      ));
    }

    if (score.sharpness < 40) {
      feedback.add(QualityFeedback(
        type: QualityFeedbackType.warning,
        message: 'Image is blurry. Hold camera steady.',
      ));
    }

    if (score.isAcceptable && feedback.isEmpty) {
      feedback.add(QualityFeedback(
        type: QualityFeedbackType.success,
        message: 'Good photo quality!',
      ));
    }

    return feedback;
  }

  // ==================== Face-Specific Quality Gates ====================

  /// Validate face size relative to image
  static FaceSizeValidation validateFaceSize(Face face, ui.Size imageSize) {
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

  /// Validate head pose angles
  static PoseValidation validatePose(Face face) {
    final pitch = face.headEulerAngleX ?? 0.0;
    final yaw = face.headEulerAngleY ?? 0.0;
    final roll = face.headEulerAngleZ ?? 0.0;

    return PoseValidation.validate(
      pitch: pitch,
      yaw: yaw,
      roll: roll,
    );
  }

  /// Validate lighting symmetry by analyzing brightness on left/right sides of face
  static Future<LightingValidation> validateLighting(
    Uint8List imageData,
    Face face,
  ) async {
    try {
      final image = img.decodeImage(imageData);
      if (image == null) {
        return LightingValidation.validate(
          leftBrightness: 0.5,
          rightBrightness: 0.5,
        );
      }

      final boundingBox = face.boundingBox;
      final centerX = boundingBox.center.dx.toInt();
      final topY = boundingBox.top.toInt().clamp(0, image.height - 1);
      final bottomY = boundingBox.bottom.toInt().clamp(0, image.height - 1);
      final leftX = boundingBox.left.toInt().clamp(0, image.width - 1);
      final rightX = boundingBox.right.toInt().clamp(0, image.width - 1);

      // Sample left side of face
      double leftBrightness = _sampleRegionBrightness(
        image,
        leftX,
        topY,
        centerX,
        bottomY,
      );

      // Sample right side of face
      double rightBrightness = _sampleRegionBrightness(
        image,
        centerX,
        topY,
        rightX,
        bottomY,
      );

      // Normalize to 0-1 range
      leftBrightness = leftBrightness / 255.0;
      rightBrightness = rightBrightness / 255.0;

      return LightingValidation.validate(
        leftBrightness: leftBrightness,
        rightBrightness: rightBrightness,
      );
    } catch (e) {
      return LightingValidation.validate(
        leftBrightness: 0.5,
        rightBrightness: 0.5,
      );
    }
  }

  /// Sample average brightness of a region
  static double _sampleRegionBrightness(
    img.Image image,
    int x1,
    int y1,
    int x2,
    int y2,
  ) {
    double totalBrightness = 0;
    int pixelCount = 0;

    // Ensure valid bounds
    x1 = x1.clamp(0, image.width - 1);
    x2 = x2.clamp(0, image.width - 1);
    y1 = y1.clamp(0, image.height - 1);
    y2 = y2.clamp(0, image.height - 1);

    if (x1 >= x2 || y1 >= y2) return 128;

    final step = max(1, ((x2 - x1) * (y2 - y1)) ~/ 100);

    for (int y = y1; y < y2; y += step) {
      for (int x = x1; x < x2; x += step) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final brightness = 0.299 * r + 0.587 * g + 0.114 * b;
        totalBrightness += brightness;
        pixelCount++;
      }
    }

    return pixelCount > 0 ? totalBrightness / pixelCount : 128;
  }

  /// Complete face quality validation
  static Future<FaceQualityResult> validateFaceQuality(
    Uint8List imageData,
    Face face,
    ui.Size imageSize,
  ) async {
    final faceSize = validateFaceSize(face, imageSize);
    final pose = validatePose(face);
    final lighting = await validateLighting(imageData, face);

    final qualityGate = QualityGateResult.fromValidations(
      faceSize: faceSize,
      pose: pose,
      lighting: lighting,
    );

    final feedback = getFaceQualityFeedback(
      faceSize: faceSize,
      pose: pose,
      lighting: lighting,
    );

    return FaceQualityResult(
      qualityGate: qualityGate,
      faceSize: faceSize,
      pose: pose,
      lighting: lighting,
      feedback: feedback,
    );
  }

  /// Get feedback messages for face quality issues
  static List<QualityFeedback> getFaceQualityFeedback({
    required FaceSizeValidation faceSize,
    required PoseValidation pose,
    required LightingValidation lighting,
  }) {
    final feedback = <QualityFeedback>[];

    // Face size feedback
    if (!faceSize.passed) {
      if (faceSize.faceWidthRatio < faceSize.minRequired) {
        feedback.add(QualityFeedback(
          type: QualityFeedbackType.warning,
          message: 'Face is too small. Move closer to the camera.',
        ));
      } else {
        feedback.add(QualityFeedback(
          type: QualityFeedbackType.warning,
          message: 'Face is too large. Move back from the camera.',
        ));
      }
    }

    // Pose feedback
    if (!pose.passed) {
      if (pose.pitch.abs() > AppConstants.maxPoseAngleDegrees) {
        feedback.add(QualityFeedback(
          type: QualityFeedbackType.warning,
          message: pose.pitch > 0
              ? 'Tilt your head down slightly.'
              : 'Tilt your head up slightly.',
        ));
      }
      if (pose.yaw.abs() > AppConstants.maxPoseAngleDegrees) {
        feedback.add(QualityFeedback(
          type: QualityFeedbackType.warning,
          message: 'Face the camera directly.',
        ));
      }
      if (pose.roll.abs() > AppConstants.maxPoseAngleDegrees) {
        feedback.add(QualityFeedback(
          type: QualityFeedbackType.warning,
          message: 'Keep your head level.',
        ));
      }
    }

    // Lighting feedback
    if (!lighting.passed) {
      feedback.add(QualityFeedback(
        type: QualityFeedbackType.warning,
        message: 'Uneven lighting detected. Face a light source directly.',
      ));
    }

    // Success message
    if (feedback.isEmpty) {
      feedback.add(QualityFeedback(
        type: QualityFeedbackType.success,
        message: 'Perfect positioning! Ready to capture.',
      ));
    }

    return feedback;
  }

  /// Calculate overall face quality score (0-100)
  static double calculateFaceQualityScore(FaceQualityResult result) {
    double score = 100;

    // Face size penalty
    if (!result.faceSize.passed) {
      final ratio = result.faceSize.faceWidthRatio;
      if (ratio < result.faceSize.minRequired) {
        score -= (result.faceSize.minRequired - ratio) * 100;
      } else {
        score -= (ratio - result.faceSize.maxAllowed) * 50;
      }
    }

    // Pose penalty
    if (!result.pose.passed) {
      final maxAngle = [
        result.pose.pitch.abs(),
        result.pose.yaw.abs(),
        result.pose.roll.abs(),
      ].reduce(max);
      score -= (maxAngle - AppConstants.maxPoseAngleDegrees) * 2;
    }

    // Lighting penalty
    if (!result.lighting.passed) {
      score -= result.lighting.asymmetryPercent * 0.5;
    }

    return score.clamp(0, 100);
  }
}

/// Complete face quality result
class FaceQualityResult {
  final QualityGateResult qualityGate;
  final FaceSizeValidation faceSize;
  final PoseValidation pose;
  final LightingValidation lighting;
  final List<QualityFeedback> feedback;

  FaceQualityResult({
    required this.qualityGate,
    required this.faceSize,
    required this.pose,
    required this.lighting,
    required this.feedback,
  });

  bool get passed => qualityGate.passed;

  double get score => QualityValidator.calculateFaceQualityScore(this);
}

/// Quality feedback message
class QualityFeedback {
  final QualityFeedbackType type;
  final String message;

  QualityFeedback({
    required this.type,
    required this.message,
  });
}

enum QualityFeedbackType {
  success,
  warning,
  error,
}
