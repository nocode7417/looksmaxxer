import 'dart:math';
import 'dart:typed_data';
import '../data/models/photo_model.dart';
import '../core/constants/app_constants.dart';

/// Analysis engine for generating facial metrics (mock implementation)
/// Matches the original React app's analysis.js functionality
class AnalysisEngine {
  static final Random _random = Random();

  /// Analyze a photo and generate metrics
  /// Uses image seed for consistent results with same image
  static Future<Map<String, MetricValue>> analyzePhoto(
    Uint8List imageData,
  ) async {
    // Simulate processing delay (anti-dopamine design)
    final delayMs = AppConstants.analysisDelayMinMs +
        _random.nextInt(
          AppConstants.analysisDelayMaxMs - AppConstants.analysisDelayMinMs,
        );
    await Future.delayed(Duration(milliseconds: delayMs));

    // Generate seed from image data for consistency
    final seed = _generateImageSeed(imageData);
    final seededRandom = Random(seed);

    final now = DateTime.now();

    return {
      'facialSymmetry': MetricValue(
        value: _generateMetricValue(seededRandom, 65, 95),
        confidence: _generateConfidence(seededRandom),
        measuredAt: now,
      ),
      'proportionalHarmony': MetricValue(
        value: _generateMetricValue(seededRandom, -8, 8),
        confidence: _generateConfidence(seededRandom),
        measuredAt: now,
      ),
      'canthalTilt': MetricValue(
        value: _generateMetricValue(seededRandom, -2, 10),
        confidence: _generateConfidence(seededRandom),
        measuredAt: now,
      ),
      'skinTexture': MetricValue(
        value: _generateMetricValue(seededRandom, 55, 90),
        confidence: _generateConfidence(seededRandom),
        measuredAt: now,
      ),
      'skinClarity': MetricValue(
        value: _generateMetricValue(seededRandom, 60, 92),
        confidence: _generateConfidence(seededRandom),
        measuredAt: now,
      ),
      'jawDefinition': MetricValue(
        value: _generateMetricValue(seededRandom, 50, 88),
        confidence: _generateConfidence(seededRandom),
        measuredAt: now,
      ),
      'cheekboneProminence': MetricValue(
        value: _generateMetricValue(seededRandom, 55, 85),
        confidence: _generateConfidence(seededRandom),
        measuredAt: now,
      ),
    };
  }

  /// Generate a seed from image data for consistent results
  static int _generateImageSeed(Uint8List imageData) {
    // Sample pixels to generate a seed
    int seed = 0;
    final step = max(1, imageData.length ~/ 100);
    for (int i = 0; i < imageData.length; i += step) {
      seed = (seed * 31 + imageData[i]) & 0x7FFFFFFF;
    }
    return seed;
  }

  /// Generate a metric value within range with slight variance
  static double _generateMetricValue(Random random, double min, double max) {
    final base = min + random.nextDouble() * (max - min);
    // Add small variance for realism
    final variance = (random.nextDouble() - 0.5) * 2;
    return (base + variance).clamp(min, max);
  }

  /// Generate confidence score (typically 60-95%)
  static double _generateConfidence(Random random) {
    return 60 + random.nextDouble() * 35;
  }

  /// Calculate baseline metrics from multiple photos
  static Map<String, MetricValue> calculateBaseline(
    List<Map<String, MetricValue>> photoMetrics,
  ) {
    if (photoMetrics.isEmpty) return {};

    final baseline = <String, MetricValue>{};
    final metricIds = photoMetrics.first.keys;

    for (final metricId in metricIds) {
      final values = photoMetrics
          .where((m) => m.containsKey(metricId))
          .map((m) => m[metricId]!)
          .toList();

      if (values.isEmpty) continue;

      // Calculate weighted average based on confidence
      double weightedSum = 0;
      double totalWeight = 0;
      double maxConfidence = 0;

      for (final value in values) {
        weightedSum += value.value * value.confidence;
        totalWeight += value.confidence;
        maxConfidence = max(maxConfidence, value.confidence);
      }

      final averageValue = weightedSum / totalWeight;

      baseline[metricId] = MetricValue(
        value: averageValue,
        confidence: maxConfidence * 0.9, // Slightly reduce confidence for baseline
        measuredAt: DateTime.now(),
      );
    }

    return baseline;
  }

  /// Calculate metric change from baseline
  static double calculateChange(
    MetricValue current,
    MetricValue baseline,
  ) {
    return current.value - baseline.value;
  }

  /// Determine trend direction
  static MetricTrend getTrend(double change, String metricId) {
    final config = MetricConfig.getById(metricId);
    if (config == null) return MetricTrend.stable;

    // For proportional harmony, closer to 0 is better
    if (metricId == 'proportionalHarmony') {
      if (change.abs() < 0.5) return MetricTrend.stable;
      // If current is closer to 0 than baseline was, that's improvement
      return MetricTrend.stable; // Simplified for now
    }

    if (change.abs() < 1) return MetricTrend.stable;
    if (config.higherIsBetter) {
      return change > 0 ? MetricTrend.improving : MetricTrend.declining;
    } else {
      return change < 0 ? MetricTrend.improving : MetricTrend.declining;
    }
  }
}

/// Metric trend direction
enum MetricTrend {
  improving,
  stable,
  declining,
}

extension MetricTrendExtension on MetricTrend {
  String get label {
    switch (this) {
      case MetricTrend.improving:
        return 'Improving';
      case MetricTrend.stable:
        return 'Stable';
      case MetricTrend.declining:
        return 'Declining';
    }
  }

  String get icon {
    switch (this) {
      case MetricTrend.improving:
        return '\u2191'; // Up arrow
      case MetricTrend.stable:
        return '\u2192'; // Right arrow
      case MetricTrend.declining:
        return '\u2193'; // Down arrow
    }
  }
}
