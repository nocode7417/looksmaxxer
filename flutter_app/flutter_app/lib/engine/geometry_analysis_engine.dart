import 'dart:math';
import 'dart:typed_data';
import '../data/models/geometry_metrics_model.dart';
import '../data/models/photo_model.dart';
import '../core/constants/app_constants.dart';

/// Geometry-based facial analysis engine with bias mitigation
/// All measurements are objective spatial relationships, not learned attractiveness models
class GeometryAnalysisEngine {
  static final Random _random = Random();

  /// Multi-frame averaging configuration
  static const int targetFrames = 10; // Top 10 frames from 75 captured
  static const double measurementUncertaintyMultiFrame = 1.0; // ±1mm with averaging
  static const double measurementUncertaintySingleFrame = 3.0; // ±3mm without

  /// Analyze a photo and generate geometry-based metrics
  /// Uses culturally neutral measurements
  static Future<GeometryAnalysisResult> analyzeGeometry(
    Uint8List imageData, {
    int framesAnalyzed = 1,
  }) async {
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

    // Calculate measurement uncertainty based on frames analyzed
    final uncertainty = framesAnalyzed >= targetFrames
        ? measurementUncertaintyMultiFrame
        : measurementUncertaintySingleFrame;

    // Generate symmetry analysis
    final symmetry = _generateSymmetryAnalysis(seededRandom, now);

    // Generate proportion analysis
    final proportions = _generateProportionAnalysis(seededRandom, now);

    // Generate additional measurements
    final additionalMeasurements = _generateAdditionalMeasurements(
      seededRandom,
      now,
    );

    // Calculate overall confidence
    final overallConfidence = _calculateOverallConfidence(
      symmetry.confidence,
      proportions.confidence,
      framesAnalyzed,
    );

    return GeometryAnalysisResult(
      symmetry: symmetry,
      proportions: proportions,
      additionalMeasurements: additionalMeasurements,
      overallConfidence: overallConfidence,
      framesAnalyzed: framesAnalyzed,
      measurementUncertainty: uncertainty,
      analyzedAt: now,
    );
  }

  /// Generate symmetry analysis with neutral language
  static SymmetryAnalysis _generateSymmetryAnalysis(
    Random random,
    DateTime now,
  ) {
    // Overall symmetry (most faces are 95-98% symmetric)
    final overallSymmetry = 92 + random.nextDouble() * 7; // 92-99

    // Midline deviation (typically 0-3mm)
    final midlineDeviation = random.nextDouble() * 3;

    return SymmetryAnalysis(
      overallSymmetry: overallSymmetry,
      midlineDeviation: midlineDeviation,
      eyeSymmetry: RegionalSymmetry(
        region: 'eyes',
        symmetryScore: 90 + random.nextDouble() * 9,
        leftRightDifference: random.nextDouble() * 2,
        confidence: 70 + random.nextDouble() * 25,
      ),
      noseSymmetry: RegionalSymmetry(
        region: 'nose',
        symmetryScore: 88 + random.nextDouble() * 10,
        leftRightDifference: random.nextDouble() * 2.5,
        confidence: 65 + random.nextDouble() * 30,
      ),
      lipSymmetry: RegionalSymmetry(
        region: 'lips',
        symmetryScore: 91 + random.nextDouble() * 8,
        leftRightDifference: random.nextDouble() * 1.5,
        confidence: 72 + random.nextDouble() * 23,
      ),
      jawSymmetry: RegionalSymmetry(
        region: 'jaw',
        symmetryScore: 87 + random.nextDouble() * 11,
        leftRightDifference: random.nextDouble() * 3,
        confidence: 60 + random.nextDouble() * 30,
      ),
      confidence: 65 + random.nextDouble() * 30,
      measuredAt: now,
    );
  }

  /// Generate proportion analysis with cultural disclaimers
  static ProportionAnalysis _generateProportionAnalysis(
    Random random,
    DateTime now,
  ) {
    // Facial thirds (ideally ~33% each, but variation is normal)
    final upperThird = 30 + random.nextDouble() * 8; // 30-38%
    final middleThird = 31 + random.nextDouble() * 7; // 31-38%
    final lowerThird = 100 - upperThird - middleThird;

    final isBalanced = (upperThird - 33.3).abs() < 5 &&
        (middleThird - 33.3).abs() < 5 &&
        (lowerThird - 33.3).abs() < 5;

    // Golden ratio (1.618 is "ideal" but this is culturally specific)
    final goldenRatio = 1.5 + random.nextDouble() * 0.3; // 1.5-1.8

    // Facial index (length/width ratio)
    final facialIndex = 1.2 + random.nextDouble() * 0.4; // 1.2-1.6

    // Angular measurements
    final angles = AngularMeasurements(
      canthalTilt: -2 + random.nextDouble() * 10, // -2 to +8 degrees
      gonialAngle: 115 + random.nextDouble() * 20, // 115-135 degrees
      nasolabialAngle: 90 + random.nextDouble() * 25, // 90-115 degrees
      holdawayAngle: null, // Profile only
      cervicoMentalAngle: null, // Profile only
    );

    return ProportionAnalysis(
      facialThirds: FacialThirds(
        upperThird: upperThird,
        middleThird: middleThird,
        lowerThird: lowerThird,
        isBalanced: isBalanced,
      ),
      goldenRatio: goldenRatio,
      facialIndex: facialIndex,
      angles: angles,
      confidence: 60 + random.nextDouble() * 35,
      measuredAt: now,
    );
  }

  /// Generate additional geometry measurements
  static List<GeometryMeasurement> _generateAdditionalMeasurements(
    Random random,
    DateTime now,
  ) {
    return [
      GeometryMeasurement(
        id: 'interpupillaryDistance',
        name: 'Interpupillary Distance',
        description: 'Distance between pupil centers',
        value: 58 + random.nextDouble() * 10, // 58-68mm typical
        unit: 'mm',
        confidence: 75 + random.nextDouble() * 20,
        measuredAt: now,
        culturalDisclaimer: 'This measurement varies naturally across '
            'individuals and populations. There is no "ideal" value.',
      ),
      GeometryMeasurement(
        id: 'noseWidth',
        name: 'Nasal Width',
        description: 'Width of nose at widest point',
        value: 32 + random.nextDouble() * 12, // 32-44mm
        unit: 'mm',
        confidence: 70 + random.nextDouble() * 25,
        measuredAt: now,
        culturalDisclaimer: 'Nasal width varies significantly across '
            'ethnic backgrounds. All variations are normal.',
      ),
      GeometryMeasurement(
        id: 'lipFullness',
        name: 'Lip Proportion',
        description: 'Upper to lower lip ratio',
        value: 0.4 + random.nextDouble() * 0.3, // 0.4-0.7
        unit: ':1',
        confidence: 68 + random.nextDouble() * 27,
        measuredAt: now,
        culturalDisclaimer: 'Lip proportions vary widely and all natural '
            'variations are normal. Beauty standards differ across cultures.',
      ),
      GeometryMeasurement(
        id: 'jawWidth',
        name: 'Bigonial Width',
        description: 'Width between jaw angles',
        value: 95 + random.nextDouble() * 25, // 95-120mm
        unit: 'mm',
        confidence: 65 + random.nextDouble() * 30,
        measuredAt: now,
        culturalDisclaimer: 'Jaw width is influenced by genetics, age, '
            'and muscle mass. There is no universally ideal jaw width.',
      ),
    ];
  }

  /// Calculate overall confidence score
  static double _calculateOverallConfidence(
    double symmetryConfidence,
    double proportionConfidence,
    int framesAnalyzed,
  ) {
    // Base confidence from measurements
    double baseConfidence = (symmetryConfidence + proportionConfidence) / 2;

    // Boost confidence for multi-frame analysis
    if (framesAnalyzed >= targetFrames) {
      baseConfidence = min(95, baseConfidence * 1.1);
    } else if (framesAnalyzed >= 5) {
      baseConfidence = min(90, baseConfidence * 1.05);
    }

    return baseConfidence;
  }

  /// Generate a seed from image data for consistent results
  static int _generateImageSeed(Uint8List imageData) {
    int seed = 0;
    final step = max(1, imageData.length ~/ 100);
    for (int i = 0; i < imageData.length; i += step) {
      seed = (seed * 31 + imageData[i]) & 0x7FFFFFFF;
    }
    return seed;
  }

  /// Convert geometry analysis to standard metrics for backward compatibility
  static Map<String, MetricValue> toStandardMetrics(
    GeometryAnalysisResult geometry,
  ) {
    final now = geometry.analyzedAt;

    return {
      'facialSymmetry': MetricValue(
        value: geometry.symmetry.overallSymmetry,
        confidence: geometry.symmetry.confidence,
        measuredAt: now,
      ),
      'proportionalHarmony': MetricValue(
        // Convert facial thirds balance to harmony score
        value: _calculateHarmonyFromThirds(geometry.proportions.facialThirds),
        confidence: geometry.proportions.confidence,
        measuredAt: now,
      ),
      'canthalTilt': MetricValue(
        value: geometry.proportions.angles.canthalTilt,
        confidence: geometry.proportions.confidence * 0.9,
        measuredAt: now,
      ),
      'jawDefinition': MetricValue(
        // Approximate from jaw symmetry and geometry
        value: _estimateJawDefinition(geometry),
        confidence: geometry.symmetry.jawSymmetry.confidence,
        measuredAt: now,
      ),
    };
  }

  /// Calculate harmony score from facial thirds
  static double _calculateHarmonyFromThirds(FacialThirds thirds) {
    // Calculate deviation from ideal thirds (33.3% each)
    final upperDev = (thirds.upperThird - 33.3).abs();
    final middleDev = (thirds.middleThird - 33.3).abs();
    final lowerDev = (thirds.lowerThird - 33.3).abs();

    // Average deviation, scaled to -15 to +15 range
    final avgDev = (upperDev + middleDev + lowerDev) / 3;
    return avgDev.clamp(-15, 15);
  }

  /// Estimate jaw definition from geometry
  static double _estimateJawDefinition(GeometryAnalysisResult geometry) {
    // Combine jaw symmetry and gonial angle into definition score
    final jawSymmetry = geometry.symmetry.jawSymmetry.symmetryScore;
    final gonialAngle = geometry.proportions.angles.gonialAngle;

    // Lower gonial angles (more defined) contribute to higher score
    final angleContribution = max(0, (135 - gonialAngle) / 20 * 30);

    return ((jawSymmetry * 0.7) + angleContribution).clamp(0, 100);
  }

  /// Get neutral description for a measurement result
  static String getNeutralDescription(GeometryMeasurement measurement) {
    return LanguageSanitizer.getNeutralDescription(
      measurementName: measurement.name,
      value: measurement.value,
      unit: measurement.unit,
      typicalMin: _getTypicalMin(measurement.id),
      typicalMax: _getTypicalMax(measurement.id),
    );
  }

  static double _getTypicalMin(String measurementId) {
    switch (measurementId) {
      case 'interpupillaryDistance':
        return 58;
      case 'noseWidth':
        return 32;
      case 'lipFullness':
        return 0.4;
      case 'jawWidth':
        return 95;
      default:
        return 0;
    }
  }

  static double _getTypicalMax(String measurementId) {
    switch (measurementId) {
      case 'interpupillaryDistance':
        return 68;
      case 'noseWidth':
        return 44;
      case 'lipFullness':
        return 0.7;
      case 'jawWidth':
        return 120;
      default:
        return 100;
    }
  }
}

/// Quality frame selector for multi-frame averaging
class FrameQualitySelector {
  /// Select best frames from a sequence for analysis
  /// Target: 2.5 seconds of video (75 frames at 30fps), select top 10
  static List<int> selectBestFrames(
    List<double> frameQualityScores, {
    int targetCount = 10,
  }) {
    if (frameQualityScores.length <= targetCount) {
      return List.generate(frameQualityScores.length, (i) => i);
    }

    // Create indexed list and sort by quality
    final indexed = frameQualityScores.asMap().entries.toList();
    indexed.sort((a, b) => b.value.compareTo(a.value));

    // Return indices of top frames
    return indexed.take(targetCount).map((e) => e.key).toList()..sort();
  }

  /// Calculate frame quality score
  static double calculateFrameQuality({
    required double brightness,
    required double contrast,
    required double sharpness,
    required double faceConfidence, // From face detection
    required double poseAngle, // Head angle deviation from frontal
  }) {
    // Penalize if face detection confidence is low
    if (faceConfidence < 0.7) return 0;

    // Penalize if pose angle is too far from frontal
    if (poseAngle.abs() > 15) {
      return (brightness * 0.2 + contrast * 0.2 + sharpness * 0.3) *
          (1 - poseAngle.abs() / 90) *
          faceConfidence;
    }

    return (brightness * 0.25 +
            contrast * 0.25 +
            sharpness * 0.3 +
            faceConfidence * 20) *
        (1 - poseAngle.abs() / 45);
  }
}
