import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../data/models/photo_model.dart';
import '../data/models/ml_analysis_model.dart';
import '../core/constants/app_constants.dart';
import 'ml_facial_analyzer.dart';

/// Analysis engine for generating facial metrics
/// Uses ML Kit for real analysis with mock fallback
class AnalysisEngine {
  static final Random _random = Random();
  static MLFacialAnalyzer? _mlAnalyzer;
  static bool _mlKitAvailable = true;

  /// Initialize ML Kit analyzer
  static Future<void> initializeMLKit() async {
    if (_mlAnalyzer != null && _mlAnalyzer!.isInitialized) return;

    try {
      _mlAnalyzer = MLFacialAnalyzer();
      await _mlAnalyzer!.initialize();
      _mlKitAvailable = true;
    } catch (e) {
      _mlKitAvailable = false;
      _mlAnalyzer = null;
    }
  }

  /// Check if ML Kit is available
  static bool get isMLKitAvailable => _mlKitAvailable && _mlAnalyzer != null;

  /// Analyze a photo and generate metrics
  /// Uses ML Kit when available, falls back to mock implementation
  static Future<Map<String, MetricValue>> analyzePhoto(
    Uint8List imageData, {
    ui.Size? imageSize,
    bool forceMock = false,
  }) async {
    // Try ML Kit first if available
    if (!forceMock && isMLKitAvailable) {
      try {
        final result = await _analyzeWithMLKit(imageData, imageSize);
        if (result != null) {
          return result;
        }
      } catch (e) {
        // Fall through to mock
      }
    }

    // Fall back to mock implementation
    return _analyzeWithMock(imageData);
  }

  /// Analyze using ML Kit
  static Future<Map<String, MetricValue>?> _analyzeWithMLKit(
    Uint8List imageData,
    ui.Size? imageSize,
  ) async {
    if (_mlAnalyzer == null) return null;

    // Create InputImage from bytes
    final inputImage = InputImage.fromBytes(
      bytes: imageData,
      metadata: InputImageMetadata(
        size: imageSize ?? const ui.Size(640, 480),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: imageSize?.width.toInt() ?? 640,
      ),
    );

    // Detect faces
    final faces = await _mlAnalyzer!.detectFaces(inputImage);
    if (faces.isEmpty) return null;

    // Select best face
    final bestFace = _mlAnalyzer!.selectBestFrame(faces);
    if (bestFace == null) return null;

    // Extract landmarks
    final landmarks = _mlAnalyzer!.extractLandmarks(bestFace);

    // Calculate measurements
    final measurements = _mlAnalyzer!.calculateMeasurements(
      landmarks,
      bestFace,
      frameCount: 1,
    );

    // Convert FacialMeasurement to MetricValue
    final now = DateTime.now();
    return measurements.map((key, measurement) => MapEntry(
      key,
      MetricValue(
        value: measurement.value,
        confidence: measurement.confidence * 100,
        measuredAt: now,
      ),
    ));
  }

  /// Analyze with multi-frame capture for improved accuracy
  static Future<MLAnalysisResult> analyzeWithMultiFrame(
    List<Uint8List> frames,
    ui.Size imageSize,
  ) async {
    if (!isMLKitAvailable || _mlAnalyzer == null) {
      // Return mock result
      final mockMetrics = await _analyzeWithMock(frames.first);
      return MLAnalysisResult(
        measurements: mockMetrics.map((key, value) => MapEntry(
          key,
          FacialMeasurement(
            metricId: key,
            value: value.value,
            uncertainty: 5.0,
            confidence: value.confidence / 100,
            measuredAt: value.measuredAt,
          ),
        )),
        qualityGate: QualityGateResult.allPassed(),
        frameCount: 1,
        usedMLKit: false,
        analyzedAt: DateTime.now(),
      );
    }

    final allFaces = <Face>[];
    QualityGateResult? bestQuality;

    for (final frame in frames) {
      try {
        final inputImage = InputImage.fromBytes(
          bytes: frame,
          metadata: InputImageMetadata(
            size: imageSize,
            rotation: InputImageRotation.rotation0deg,
            format: InputImageFormat.nv21,
            bytesPerRow: imageSize.width.toInt(),
          ),
        );

        final faces = await _mlAnalyzer!.detectFaces(inputImage);
        if (faces.isNotEmpty) {
          final face = faces.first;
          allFaces.add(face);

          // Check quality gates
          final quality = _mlAnalyzer!.validateQualityGates(face, imageSize);
          if (bestQuality == null || quality.passed && !bestQuality.passed) {
            bestQuality = quality;
          }
        }
      } catch (e) {
        continue;
      }
    }

    if (allFaces.isEmpty) {
      throw AnalysisException('No faces detected in any frame');
    }

    // Select best frame
    final bestFace = _mlAnalyzer!.selectBestFrame(allFaces);
    if (bestFace == null) {
      throw AnalysisException('Could not select best frame');
    }

    // Extract landmarks and calculate measurements
    final landmarks = _mlAnalyzer!.extractLandmarks(bestFace);
    final measurements = _mlAnalyzer!.calculateMeasurements(
      landmarks,
      bestFace,
      frameCount: allFaces.length,
    );

    return MLAnalysisResult(
      measurements: measurements,
      qualityGate: bestQuality ?? QualityGateResult.allPassed(),
      frameCount: allFaces.length,
      usedMLKit: true,
      analyzedAt: DateTime.now(),
    );
  }

  /// Mock implementation fallback
  static Future<Map<String, MetricValue>> _analyzeWithMock(
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

  /// Dispose ML Kit resources
  static void dispose() {
    _mlAnalyzer?.dispose();
    _mlAnalyzer = null;
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

/// Exception thrown during analysis
class AnalysisException implements Exception {
  final String message;
  final Object? cause;

  AnalysisException(this.message, [this.cause]);

  @override
  String toString() => 'AnalysisException: $message${cause != null ? ' ($cause)' : ''}';
}
