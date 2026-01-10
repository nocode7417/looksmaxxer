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
    if (!_isInitialized) {
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
class MockPoseDetectionService extends PoseDetectionService {
  final StreamController<PoseData> _controller = StreamController<PoseData>.broadcast();
  Timer? _mockTimer;

  @override
  Future<bool> initialize({
    required CameraDescription camera,
    required double targetFps,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isInitialized = true;
    _startMockStream();
    return true;
  }

  void _startMockStream() {
    // Generate mock pose data at 30fps
    _mockTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
      _controller.add(_generateMockPose());
    });
  }

  PoseData _generateMockPose() {
    // Generate realistic mock landmarks
    return PoseData(
      landmarks: {
        BodyLandmark.nose: const Landmark(x: 0.5, y: 0.3, confidence: 0.9),
        BodyLandmark.leftEye: const Landmark(x: 0.48, y: 0.28, confidence: 0.9),
        BodyLandmark.rightEye: const Landmark(x: 0.52, y: 0.28, confidence: 0.9),
        BodyLandmark.leftEar: const Landmark(x: 0.45, y: 0.3, confidence: 0.85),
        BodyLandmark.rightEar: const Landmark(x: 0.55, y: 0.3, confidence: 0.85),
        BodyLandmark.leftShoulder: const Landmark(x: 0.4, y: 0.5, confidence: 0.9),
        BodyLandmark.rightShoulder: const Landmark(x: 0.6, y: 0.5, confidence: 0.9),
        BodyLandmark.leftElbow: const Landmark(x: 0.35, y: 0.65, confidence: 0.85),
        BodyLandmark.rightElbow: const Landmark(x: 0.65, y: 0.65, confidence: 0.85),
        BodyLandmark.leftWrist: const Landmark(x: 0.32, y: 0.75, confidence: 0.8),
        BodyLandmark.rightWrist: const Landmark(x: 0.68, y: 0.75, confidence: 0.8),
        BodyLandmark.leftHip: const Landmark(x: 0.42, y: 0.7, confidence: 0.9),
        BodyLandmark.rightHip: const Landmark(x: 0.58, y: 0.7, confidence: 0.9),
        BodyLandmark.leftKnee: const Landmark(x: 0.43, y: 0.85, confidence: 0.85),
        BodyLandmark.rightKnee: const Landmark(x: 0.57, y: 0.85, confidence: 0.85),
        BodyLandmark.leftAnkle: const Landmark(x: 0.44, y: 0.95, confidence: 0.8),
        BodyLandmark.rightAnkle: const Landmark(x: 0.56, y: 0.95, confidence: 0.8),
      },
      timestamp: DateTime.now(),
      overallConfidence: 0.87,
    );
  }

  @override
  Stream<PoseData> getPoseStream() {
    if (!_isInitialized) {
      throw StateError('Pose detection not initialized');
    }
    return _controller.stream;
  }

  @override
  Future<void> stop() async {
    _mockTimer?.cancel();
    _isInitialized = false;
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
