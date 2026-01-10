/// Platform channel bridge for native pose detection
/// Android: ML Kit Pose Detection with 33 landmarks
/// iOS: Vision framework with 17 keypoints

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import '../engine/pose_detection_engine.dart';

/// Platform channel for native pose detection
class PoseDetectionService {
  static const MethodChannel _channel = MethodChannel('com.looksmaxxer/pose_detection');
  static const EventChannel _poseStream = EventChannel('com.looksmaxxer/pose_stream');

  Stream<PoseData>? _poseDataStream;
  bool _isInitialized = false;

  /// Protected getter for subclasses
  bool get isInitialized => _isInitialized;

  /// Protected setter for subclasses
  set isInitializedFlag(bool value) => _isInitialized = value;

  /// Initialize pose detection with camera
  Future<bool> initialize({
    required CameraDescription camera,
    required double targetFps, // 30fps target
  }) async {
    try {
      final result = await _channel.invokeMethod('initialize', {
        'cameraName': camera.name,
        'targetFps': targetFps,
        'enableSmoothing': true, // Reduce jitter
        'confidenceThreshold': 0.5, // Minimum confidence for landmarks
      });

      _isInitialized = result == true;
      return _isInitialized;
    } on PlatformException catch (e) {
      print('Failed to initialize pose detection: ${e.message}');
      return false;
    }
  }

  /// Start pose detection stream
  Stream<PoseData> getPoseStream() {
    if (!isInitialized) {
      throw StateError('Pose detection not initialized');
    }

    _poseDataStream ??= _poseStream
        .receiveBroadcastStream()
        .map((event) => _parsePoseData(event as Map))
        .where((pose) => pose.overallConfidence > 0.5); // Filter low-confidence

    return _poseDataStream!;
  }

  /// Parse native pose data to PoseData
  PoseData _parsePoseData(Map data) {
    final landmarks = <BodyLandmark, Landmark>{};
    final landmarksData = data['landmarks'] as Map;

    // Map from platform-specific landmark names to our enum
    final landmarkMap = _getLandmarkMapping();

    for (final entry in landmarkMap.entries) {
      final nativeName = entry.key;
      final ourLandmark = entry.value;

      if (landmarksData.containsKey(nativeName)) {
        final landmarkData = landmarksData[nativeName] as Map;
        landmarks[ourLandmark] = Landmark(
          x: (landmarkData['x'] as num).toDouble(),
          y: (landmarkData['y'] as num).toDouble(),
          confidence: (landmarkData['confidence'] as num).toDouble(),
        );
      }
    }

    return PoseData(
      landmarks: landmarks,
      timestamp: DateTime.now(),
      overallConfidence: (data['confidence'] as num).toDouble(),
    );
  }

  /// Map platform-specific landmark names to our enum
  /// Android ML Kit uses different names than iOS Vision
  Map<String, BodyLandmark> _getLandmarkMapping() {
    return {
      // Common names that work on both platforms
      'nose': BodyLandmark.nose,
      'leftEye': BodyLandmark.leftEye,
      'rightEye': BodyLandmark.rightEye,
      'leftEar': BodyLandmark.leftEar,
      'rightEar': BodyLandmark.rightEar,
      'leftShoulder': BodyLandmark.leftShoulder,
      'rightShoulder': BodyLandmark.rightShoulder,
      'leftElbow': BodyLandmark.leftElbow,
      'rightElbow': BodyLandmark.rightElbow,
      'leftWrist': BodyLandmark.leftWrist,
      'rightWrist': BodyLandmark.rightWrist,
      'leftHip': BodyLandmark.leftHip,
      'rightHip': BodyLandmark.rightHip,
      'leftKnee': BodyLandmark.leftKnee,
      'rightKnee': BodyLandmark.rightKnee,
      'leftAnkle': BodyLandmark.leftAnkle,
      'rightAnkle': BodyLandmark.rightAnkle,
    };
  }

  /// Stop pose detection
  Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
      _isInitialized = false;
    } on PlatformException catch (e) {
      print('Failed to stop pose detection: ${e.message}');
    }
  }

  /// Get performance metrics
  Future<PerformanceMetrics> getPerformanceMetrics() async {
    try {
      final result = await _channel.invokeMethod('getPerformanceMetrics');
      return PerformanceMetrics.fromMap(result as Map);
    } on PlatformException catch (e) {
      print('Failed to get performance metrics: ${e.message}');
      return PerformanceMetrics.empty();
    }
  }

  /// Enable/disable haptic feedback on rep completion
  Future<void> setHapticFeedback(bool enabled) async {
    try {
      await _channel.invokeMethod('setHapticFeedback', {'enabled': enabled});
    } on PlatformException catch (e) {
      print('Failed to set haptic feedback: ${e.message}');
    }
  }

  /// Trigger haptic feedback manually
  Future<void> triggerHaptic({HapticType type = HapticType.light}) async {
    try {
      await _channel.invokeMethod('triggerHaptic', {'type': type.name});
    } on PlatformException catch (e) {
      print('Failed to trigger haptic: ${e.message}');
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    await stop();
    _poseDataStream = null;
  }
}

/// Haptic feedback types
enum HapticType {
  light,
  medium,
  heavy,
  success,
  warning,
  error,
}

/// Performance metrics for monitoring
class PerformanceMetrics {
  final double fps; // Actual frames per second
  final double latencyMs; // Processing latency
  final double batteryDrainPercent; // Battery usage
  final int memoryUsageMb; // Memory consumption
  final int droppedFrames; // Frames dropped due to lag

  const PerformanceMetrics({
    required this.fps,
    required this.latencyMs,
    required this.batteryDrainPercent,
    required this.memoryUsageMb,
    required this.droppedFrames,
  });

  /// Check if performance meets requirements
  bool get meetsRequirements {
    return fps >= 25 && // Minimum 25fps (target 30fps)
        latencyMs < 100 && // Less than 100ms latency
        memoryUsageMb < 150 && // Less than 150MB memory
        batteryDrainPercent < 8; // Less than 8% battery per 30min
  }

  factory PerformanceMetrics.fromMap(Map data) {
    return PerformanceMetrics(
      fps: (data['fps'] as num).toDouble(),
      latencyMs: (data['latencyMs'] as num).toDouble(),
      batteryDrainPercent: (data['batteryDrainPercent'] as num).toDouble(),
      memoryUsageMb: (data['memoryUsageMb'] as num).toInt(),
      droppedFrames: (data['droppedFrames'] as num).toInt(),
    );
  }

  factory PerformanceMetrics.empty() {
    return const PerformanceMetrics(
      fps: 0,
      latencyMs: 0,
      batteryDrainPercent: 0,
      memoryUsageMb: 0,
      droppedFrames: 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fps': fps,
      'latencyMs': latencyMs,
      'batteryDrainPercent': batteryDrainPercent,
      'memoryUsageMb': memoryUsageMb,
      'droppedFrames': droppedFrames,
    };
  }
}

/// Mock implementation for development/testing without native code
/// Simulates realistic exercise movements for rep detection testing
class MockPoseDetectionService extends PoseDetectionService {
  final StreamController<PoseData> _controller = StreamController<PoseData>.broadcast();
  Timer? _mockTimer;
  int _frameCount = 0;

  // Movement simulation state
  double _movementPhase = 0.0; // 0-1 representing movement cycle

  // Rep timing: each rep takes ~3 seconds (90 frames at 30fps)
  static const int _framesPerRep = 90;

  @override
  Future<bool> initialize({
    required CameraDescription camera,
    required double targetFps,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    isInitializedFlag = true;
    _startMockStream();
    return true;
  }

  void _startMockStream() {
    // Generate mock pose data at 30fps
    _mockTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      _frameCount++;
      _updateMovementPhase();
      _controller.add(_generateAnimatedPose());
    });
  }

  void _updateMovementPhase() {
    // Create a smooth sine wave movement pattern
    // Each cycle (rep) takes _framesPerRep frames
    final cycleProgress = (_frameCount % _framesPerRep) / _framesPerRep;

    // Use sine wave for smooth movement: 0 -> 1 -> 0
    _movementPhase = (1 - (cycleProgress * 2 - 1).abs());
  }

  PoseData _generateAnimatedPose() {
    // Movement amount (0 = rest, 1 = peak of movement)
    final movement = _movementPhase;

    // === CHIN TUCK SIMULATION ===
    // At rest: ear is forward of shoulder (ear.x = 0.45, shoulder.x = 0.40)
    // At peak: ear aligns with shoulder (ear.x = 0.40, shoulder.x = 0.40)
    // The detector checks if horizontal distance DECREASES
    final earForwardOffset = 0.08 * (1 - movement); // Starts at 0.08, goes to 0

    // === PUSH-UP SIMULATION ===
    // At rest (up): elbow extended (~160° angle)
    // At peak (down): elbow bent (~90° angle)
    // Elbow moves down and out as you go down in a push-up
    final elbowDropY = movement * 0.12; // Elbow drops as arm bends
    final bodyDropY = movement * 0.05;

    // === FACE PULL SIMULATION ===
    // At rest: wrists below shoulder
    // At peak: wrists at face level (above shoulder)
    final wristRiseY = movement * 0.30;

    // === NECK CURL SIMULATION ===
    // At rest: nose level with ears
    // At peak: nose below ears (chin to chest)
    final noseDropY = movement * 0.10;

    // Base positions
    const shoulderY = 0.40;
    const elbowY = 0.55;
    const wristY = 0.65;
    const earY = 0.28;
    const noseY = 0.25;

    return PoseData(
      landmarks: {
        // Head - nose drops for neck curl
        BodyLandmark.nose: Landmark(
          x: 0.5,
          y: noseY + bodyDropY + noseDropY,
          confidence: 0.9,
        ),
        BodyLandmark.leftEye: Landmark(
          x: 0.47,
          y: noseY - 0.02 + bodyDropY,
          confidence: 0.9,
        ),
        BodyLandmark.rightEye: Landmark(
          x: 0.53,
          y: noseY - 0.02 + bodyDropY,
          confidence: 0.9,
        ),

        // Ears - move back for chin tuck (horizontal distance to shoulder decreases)
        BodyLandmark.leftEar: Landmark(
          x: 0.35 + earForwardOffset, // 0.43 at rest → 0.35 at peak (moves back toward shoulder)
          y: earY + bodyDropY,
          confidence: 0.85,
        ),
        BodyLandmark.rightEar: Landmark(
          x: 0.65 - earForwardOffset, // 0.57 at rest → 0.65 at peak
          y: earY + bodyDropY,
          confidence: 0.85,
        ),

        // Shoulders - stable reference at x=0.35 and x=0.65
        BodyLandmark.leftShoulder: Landmark(
          x: 0.35,
          y: shoulderY + bodyDropY,
          confidence: 0.9,
        ),
        BodyLandmark.rightShoulder: Landmark(
          x: 0.65,
          y: shoulderY + bodyDropY,
          confidence: 0.9,
        ),

        // Elbows - drop for push-ups (changes the shoulder-elbow-wrist angle)
        BodyLandmark.leftElbow: Landmark(
          x: 0.30,
          y: elbowY + bodyDropY + elbowDropY,
          confidence: 0.85,
        ),
        BodyLandmark.rightElbow: Landmark(
          x: 0.70,
          y: elbowY + bodyDropY + elbowDropY,
          confidence: 0.85,
        ),

        // Wrists - rise for face pulls
        BodyLandmark.leftWrist: Landmark(
          x: 0.28,
          y: wristY + bodyDropY - wristRiseY, // Goes from 0.65 to 0.35 (above shoulder)
          confidence: 0.8,
        ),
        BodyLandmark.rightWrist: Landmark(
          x: 0.72,
          y: wristY + bodyDropY - wristRiseY,
          confidence: 0.8,
        ),

        // Hips
        BodyLandmark.leftHip: Landmark(
          x: 0.42,
          y: 0.60 + bodyDropY,
          confidence: 0.9,
        ),
        BodyLandmark.rightHip: Landmark(
          x: 0.58,
          y: 0.60 + bodyDropY,
          confidence: 0.9,
        ),

        // Knees
        BodyLandmark.leftKnee: Landmark(
          x: 0.43,
          y: 0.75 + bodyDropY,
          confidence: 0.85,
        ),
        BodyLandmark.rightKnee: Landmark(
          x: 0.57,
          y: 0.75 + bodyDropY,
          confidence: 0.85,
        ),

        // Ankles - stable
        BodyLandmark.leftAnkle: const Landmark(
          x: 0.44,
          y: 0.90,
          confidence: 0.8,
        ),
        BodyLandmark.rightAnkle: const Landmark(
          x: 0.56,
          y: 0.90,
          confidence: 0.8,
        ),
      },
      timestamp: DateTime.now(),
      overallConfidence: 0.87,
    );
  }

  @override
  Stream<PoseData> getPoseStream() {
    if (!isInitialized) {
      throw StateError('Pose detection not initialized');
    }
    return _controller.stream;
  }

  @override
  Future<void> stop() async {
    _mockTimer?.cancel();
    _mockTimer = null;
    isInitializedFlag = false;
  }

  @override
  Future<PerformanceMetrics> getPerformanceMetrics() async {
    return const PerformanceMetrics(
      fps: 30.0,
      latencyMs: 35.0,
      batteryDrainPercent: 4.5,
      memoryUsageMb: 85,
      droppedFrames: 2,
    );
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
