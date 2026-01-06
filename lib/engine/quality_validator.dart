import 'dart:math';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../data/models/photo_model.dart';
import '../core/constants/app_constants.dart';

/// Quality validation for captured photos
/// Matches the original React app's QualityValidator functionality
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
