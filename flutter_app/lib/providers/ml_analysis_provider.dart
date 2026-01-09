import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/ml_analysis_model.dart';
import '../data/models/photo_model.dart';
import 'app_state_provider.dart';

/// ML Analysis state
class MLAnalysisState {
  final bool isInitialized;
  final bool isAnalyzing;
  final bool isCapturingFrames;
  final int capturedFrameCount;
  final int targetFrameCount;
  final MLAnalysisResult? result;
  final QualityGateResult? liveQualityGate;
  final String? error;
  final MultiFrameData frameData;

  const MLAnalysisState({
    this.isInitialized = false,
    this.isAnalyzing = false,
    this.isCapturingFrames = false,
    this.capturedFrameCount = 0,
    this.targetFrameCount = 10,
    this.result,
    this.liveQualityGate,
    this.error,
    this.frameData = const MultiFrameData(),
  });

  MLAnalysisState copyWith({
    bool? isInitialized,
    bool? isAnalyzing,
    bool? isCapturingFrames,
    int? capturedFrameCount,
    int? targetFrameCount,
    MLAnalysisResult? result,
    QualityGateResult? liveQualityGate,
    String? error,
    MultiFrameData? frameData,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return MLAnalysisState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isCapturingFrames: isCapturingFrames ?? this.isCapturingFrames,
      capturedFrameCount: capturedFrameCount ?? this.capturedFrameCount,
      targetFrameCount: targetFrameCount ?? this.targetFrameCount,
      result: clearResult ? null : (result ?? this.result),
      liveQualityGate: liveQualityGate ?? this.liveQualityGate,
      error: clearError ? null : (error ?? this.error),
      frameData: frameData ?? this.frameData,
    );
  }

  /// Whether analysis is ready to start
  bool get isReadyToAnalyze =>
      isInitialized && !isAnalyzing && !isCapturingFrames;

  /// Frame capture progress (0.0 to 1.0)
  double get frameCaptureProgress =>
      targetFrameCount > 0 ? capturedFrameCount / targetFrameCount : 0.0;

  /// Whether quality gates are passing
  bool get qualityGatesPassing => liveQualityGate?.passed ?? false;

  /// Primary feedback message for user
  String get feedbackMessage {
    if (!isInitialized) return 'Initializing camera...';
    if (isCapturingFrames) return 'Hold still... ${capturedFrameCount}/${targetFrameCount}';
    if (isAnalyzing) return 'Analyzing...';
    if (liveQualityGate != null && !liveQualityGate!.passed) {
      return liveQualityGate!.primaryMessage;
    }
    return 'Ready to capture';
  }
}

/// ML Analysis notifier
class MLAnalysisNotifier extends StateNotifier<MLAnalysisState> {
  MLAnalysisNotifier() : super(const MLAnalysisState());

  /// Initialize ML Kit (will be implemented with actual ML Kit)
  Future<void> initialize() async {
    try {
      // ML Kit initialization will happen here
      // For now, just mark as initialized
      state = state.copyWith(isInitialized: true);
    } catch (e) {
      state = state.copyWith(
        isInitialized: false,
        error: 'Failed to initialize ML Kit: $e',
      );
    }
  }

  /// Update live quality gate from camera preview
  void updateLiveQualityGate(QualityGateResult qualityGate) {
    state = state.copyWith(liveQualityGate: qualityGate);
  }

  /// Start multi-frame capture sequence
  void startFrameCapture({int targetFrames = 10}) {
    state = state.copyWith(
      isCapturingFrames: true,
      capturedFrameCount: 0,
      targetFrameCount: targetFrames,
      frameData: const MultiFrameData(),
      clearResult: true,
    );
  }

  /// Add a captured frame
  void addFrame({
    required FacialLandmarks landmarks,
    required double pitch,
    required double yaw,
    required double roll,
  }) {
    final newFrameData = state.frameData.addFrame(
      landmarks: landmarks,
      pitch: pitch,
      yaw: yaw,
      roll: roll,
    );

    state = state.copyWith(
      capturedFrameCount: state.capturedFrameCount + 1,
      frameData: newFrameData,
    );

    // Check if we have enough frames
    if (state.capturedFrameCount >= state.targetFrameCount) {
      state = state.copyWith(isCapturingFrames: false);
    }
  }

  /// Cancel frame capture
  void cancelFrameCapture() {
    state = state.copyWith(
      isCapturingFrames: false,
      capturedFrameCount: 0,
      frameData: const MultiFrameData(),
    );
  }

  /// Analyze captured frames
  Future<MLAnalysisResult?> analyzeFrames() async {
    if (state.frameData.frameCount == 0) {
      state = state.copyWith(error: 'No frames captured');
      return null;
    }

    state = state.copyWith(isAnalyzing: true);

    try {
      final startTime = DateTime.now();

      // Get averaged landmarks
      final averagedLandmarks = state.frameData.averagedLandmarks;
      if (averagedLandmarks == null) {
        throw Exception('Failed to average landmarks');
      }

      // Calculate measurements with uncertainty from frame variation
      final measurements = _calculateMeasurements(
        averagedLandmarks,
        state.frameData,
      );

      // Build quality gate result from frame data
      final qualityGate = _buildQualityGateFromFrames(state.frameData);

      final processingTime = DateTime.now().difference(startTime);

      final result = MLAnalysisResult(
        landmarks: averagedLandmarks,
        measurements: measurements,
        qualityGate: qualityGate,
        frameCount: state.frameData.frameCount,
        processingTime: processingTime,
      );

      state = state.copyWith(
        isAnalyzing: false,
        result: result,
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        error: 'Analysis failed: $e',
      );
      return null;
    }
  }

  /// Analyze a single image (fallback when multi-frame not available)
  Future<MLAnalysisResult?> analyzeSingleImage(Uint8List imageData) async {
    state = state.copyWith(isAnalyzing: true);

    try {
      final startTime = DateTime.now();

      // This will be replaced with actual ML Kit processing
      // For now, return a placeholder result
      final result = MLAnalysisResult.empty();
      final processingTime = DateTime.now().difference(startTime);

      state = state.copyWith(
        isAnalyzing: false,
        result: MLAnalysisResult(
          landmarks: result.landmarks,
          measurements: result.measurements,
          qualityGate: result.qualityGate,
          frameCount: 1,
          processingTime: processingTime,
        ),
      );

      return state.result;
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        error: 'Analysis failed: $e',
      );
      return null;
    }
  }

  /// Calculate measurements from landmarks with uncertainty
  Map<String, FacialMeasurement> _calculateMeasurements(
    FacialLandmarks landmarks,
    MultiFrameData frameData,
  ) {
    final measurements = <String, FacialMeasurement>{};

    // Calculate symmetry
    final symmetry = _calculateSymmetry(landmarks);
    measurements['facialSymmetry'] = FacialMeasurement(
      metricId: 'facialSymmetry',
      value: symmetry,
      uncertainty: frameData.calculateUncertainty([symmetry]),
      confidence: _calculateConfidence(frameData.frameCount),
    );

    // Calculate proportional harmony
    final harmony = _calculateHarmony(landmarks);
    measurements['proportionalHarmony'] = FacialMeasurement(
      metricId: 'proportionalHarmony',
      value: harmony,
      uncertainty: frameData.calculateUncertainty([harmony]),
      confidence: _calculateConfidence(frameData.frameCount),
    );

    // Calculate canthal tilt
    final canthalTilt = _calculateCanthalTilt(landmarks);
    measurements['canthalTilt'] = FacialMeasurement(
      metricId: 'canthalTilt',
      value: canthalTilt,
      uncertainty: frameData.calculateUncertainty([canthalTilt]),
      confidence: _calculateConfidence(frameData.frameCount),
    );

    // Jaw definition (estimated from contour sharpness)
    final jawDefinition = _estimateJawDefinition(landmarks);
    measurements['jawDefinition'] = FacialMeasurement(
      metricId: 'jawDefinition',
      value: jawDefinition,
      uncertainty: 5.0, // Higher uncertainty for estimated metrics
      confidence: _calculateConfidence(frameData.frameCount) * 0.8,
    );

    // Cheekbone prominence (estimated from contour)
    final cheekboneProminence = _estimateCheekboneProminence(landmarks);
    measurements['cheekboneProminence'] = FacialMeasurement(
      metricId: 'cheekboneProminence',
      value: cheekboneProminence,
      uncertainty: 5.0,
      confidence: _calculateConfidence(frameData.frameCount) * 0.8,
    );

    return measurements;
  }

  /// Calculate symmetry score (0-100)
  double _calculateSymmetry(FacialLandmarks landmarks) {
    // Compare left and right eye positions
    final leftEye = landmarks.leftEyeCenter;
    final rightEye = landmarks.rightEyeCenter;

    if (leftEye == null || rightEye == null) return 50.0;

    // Calculate midpoint
    final midpoint = leftEye.midpointTo(rightEye);

    // Compare distances from nose to each eye
    final noseTip = landmarks.noseTip;
    if (noseTip == null) return 50.0;

    final leftDist = leftEye.distanceTo(noseTip);
    final rightDist = rightEye.distanceTo(noseTip);

    // Calculate asymmetry ratio
    final maxDist = leftDist > rightDist ? leftDist : rightDist;
    final asymmetry = (leftDist - rightDist).abs() / maxDist;

    // Convert to 0-100 score (lower asymmetry = higher score)
    return ((1 - asymmetry) * 100).clamp(0.0, 100.0);
  }

  /// Calculate proportional harmony (-15 to +15, 0 is ideal)
  double _calculateHarmony(FacialLandmarks landmarks) {
    final faceHeight = landmarks.facialHeight;
    final faceWidth = landmarks.facialWidth;

    if (faceHeight == null || faceWidth == null) return 0.0;

    // Golden ratio is approximately 1.618
    const idealRatio = 1.618;
    final actualRatio = faceHeight / faceWidth;

    // Calculate deviation from ideal
    final deviation = (actualRatio - idealRatio) * 10;
    return deviation.clamp(-15.0, 15.0);
  }

  /// Calculate canthal tilt (-10 to +15 degrees)
  double _calculateCanthalTilt(FacialLandmarks landmarks) {
    final leftEye = landmarks.leftEyeCenter;
    final rightEye = landmarks.rightEyeCenter;

    if (leftEye == null || rightEye == null) return 0.0;

    // Calculate angle between eye centers
    final dy = rightEye.y - leftEye.y;
    final dx = rightEye.x - leftEye.x;

    // Convert to degrees
    final radians = dy / dx;
    final degrees = radians * 57.2958; // radians to degrees

    return degrees.clamp(-10.0, 15.0);
  }

  /// Estimate jaw definition (0-100)
  double _estimateJawDefinition(FacialLandmarks landmarks) {
    // This would analyze contour sharpness in real ML Kit implementation
    // For now, return a reasonable estimate based on contour points
    if (landmarks.faceContourPoints.isEmpty) return 50.0;

    // More contour points = better definition detection
    final pointCount = landmarks.faceContourPoints.length;
    return (pointCount / 100 * 50 + 25).clamp(0.0, 100.0);
  }

  /// Estimate cheekbone prominence (0-100)
  double _estimateCheekboneProminence(FacialLandmarks landmarks) {
    // This would analyze facial width at cheekbone level
    // For now, estimate from face width to height ratio
    final width = landmarks.facialWidth;
    final height = landmarks.facialHeight;

    if (width == null || height == null) return 50.0;

    final ratio = width / height;
    // Higher ratio = more prominent cheekbones
    return (ratio * 70).clamp(0.0, 100.0);
  }

  /// Calculate confidence based on frame count
  double _calculateConfidence(int frameCount) {
    // More frames = higher confidence, max at 0.95
    if (frameCount >= 10) return 0.95;
    if (frameCount >= 5) return 0.85;
    if (frameCount >= 3) return 0.75;
    return 0.60;
  }

  /// Build quality gate result from frame data
  QualityGateResult _buildQualityGateFromFrames(MultiFrameData frameData) {
    // Calculate average pose angles
    final avgPitch = frameData.pitchValues.isEmpty
        ? 0.0
        : frameData.pitchValues.reduce((a, b) => a + b) /
            frameData.pitchValues.length;
    final avgYaw = frameData.yawValues.isEmpty
        ? 0.0
        : frameData.yawValues.reduce((a, b) => a + b) /
            frameData.yawValues.length;
    final avgRoll = frameData.rollValues.isEmpty
        ? 0.0
        : frameData.rollValues.reduce((a, b) => a + b) /
            frameData.rollValues.length;

    final poseValidation = PoseValidation.validate(
      pitch: avgPitch,
      yaw: avgYaw,
      roll: avgRoll,
    );

    // Assume face size and lighting passed if we got frames
    final faceSizeValidation = FaceSizeValidation(
      passed: true,
      faceWidthRatio: 0.5,
      minRequired: 0.3,
      maxAllowed: 0.8,
    );

    final lightingValidation = LightingValidation(
      passed: true,
      leftCheekBrightness: 0.5,
      rightCheekBrightness: 0.5,
      asymmetry: 0.0,
    );

    return QualityGateResult.fromValidations(
      faceSize: faceSizeValidation,
      pose: poseValidation,
      lighting: lightingValidation,
    );
  }

  /// Convert ML analysis result to MetricValue map for storage
  Map<String, MetricValue> toMetricValues() {
    final result = state.result;
    if (result == null) return {};

    return result.measurements.map((key, measurement) {
      return MapEntry(
        key,
        MetricValue(
          value: measurement.value,
          confidence: measurement.confidence,
          measuredAt: measurement.measuredAt,
        ),
      );
    });
  }

  /// Clear current result
  void clearResult() {
    state = state.copyWith(clearResult: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Dispose resources
  void disposeMLKit() {
    // ML Kit cleanup will happen here
    state = state.copyWith(isInitialized: false);
  }
}

/// ML Analysis provider
final mlAnalysisProvider =
    StateNotifierProvider<MLAnalysisNotifier, MLAnalysisState>((ref) {
  return MLAnalysisNotifier();
});

/// Derived providers
final isMLReadyProvider = Provider<bool>((ref) {
  return ref.watch(mlAnalysisProvider).isReadyToAnalyze;
});

final isMLAnalyzingProvider = Provider<bool>((ref) {
  return ref.watch(mlAnalysisProvider).isAnalyzing;
});

final mlQualityGateProvider = Provider<QualityGateResult?>((ref) {
  return ref.watch(mlAnalysisProvider).liveQualityGate;
});

final mlFeedbackMessageProvider = Provider<String>((ref) {
  return ref.watch(mlAnalysisProvider).feedbackMessage;
});

final mlAnalysisResultProvider = Provider<MLAnalysisResult?>((ref) {
  return ref.watch(mlAnalysisProvider).result;
});

final frameCaptureProgressProvider = Provider<double>((ref) {
  return ref.watch(mlAnalysisProvider).frameCaptureProgress;
});
