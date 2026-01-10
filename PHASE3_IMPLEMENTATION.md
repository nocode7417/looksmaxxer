# Phase 3: Motion Detection Workouts - Implementation Guide

## Overview
Production-grade motion detection system for 4 looksmaxxing-optimized workouts using ML Kit (Android) and Vision framework (iOS).

## Completed Components

### 1. Data Models (`lib/data/models/workout_model.dart`)
- ✅ Comprehensive workout system with evidence-based progression
- ✅ 4 workout types: Chin Tucks, Push-Ups, Face Pulls, Neck Curls
- ✅ Progressive overload protocols (beginner/intermediate/advanced)
- ✅ Rep and set tracking with form quality scoring
- ✅ Workout program management with personal records
- ✅ Phone positioning guides for optimal detection

### 2. Pose Detection Engine (`lib/engine/pose_detection_engine.dart`)
- ✅ Platform-agnostic pose data structures
- ✅ Body landmark mapping (17-33 keypoints)
- ✅ Angle and distance calculation utilities
- ✅ Rep detectors for all 4 workouts:
  - **ChinTuckDetector**: Tracks ear-shoulder alignment with isometric holds
  - **PushUpDetector**: Elbow angle tracking with body alignment validation
  - **FacePullDetector**: Movement tempo enforcement with shoulder retraction detection
  - **NeckCurlDetector**: Safety-first design with speed monitoring
- ✅ Form validation with real-time feedback
- ✅ State machines for accurate rep counting

### 3. Platform Service (`lib/services/pose_detection_service.dart`)
- ✅ Method/Event channel bridge for native code
- ✅ Stream-based pose data delivery
- ✅ Performance metrics monitoring (FPS, latency, battery, memory)
- ✅ Haptic feedback integration
- ✅ Mock implementation for testing without native code
- ✅ 30fps target with <50ms latency requirement

## Native Implementation Requirements

### Android (ML Kit Pose Detection)

**File**: `android/app/src/main/kotlin/com/looksmaxxer/PoseDetectionPlugin.kt`

```kotlin
dependencies {
    implementation 'com.google.mlkit:pose-detection:18.0.0-beta3'
    implementation 'com.google.mlkit:pose-detection-accurate:18.0.0-beta3'
}
```

**Key Features Needed**:
- ML Kit Pose Detection API with 33 landmarks
- AccuratePoseDetector for maximum precision
- CameraX integration for camera feed
- Gyroscope + accelerometer fusion for movement validation
- Vibration feedback via VibrationEffect API
- TensorFlow Lite custom model support (optional enhancement)
- Background thread processing to maintain 60fps UI

**Implementation Steps**:
1. Create MethodChannel handler in MainActivity
2. Initialize ML Kit PoseDetector with ACCURATE mode
3. Process camera frames using CameraX ImageAnalysis
4. Convert PoseLandmarks to normalized coordinates
5. Stream pose data via EventChannel
6. Implement sensor fusion for 3D movement validation
7. Add vibration patterns for rep completion
8. Monitor performance metrics (FPS, memory, battery)

### iOS (Vision Framework)

**File**: `ios/Runner/PoseDetectionPlugin.swift`

```swift
import Vision
import CoreML
import ARKit // Optional for depth
```

**Key Features Needed**:
- VNDetectHumanBodyPoseRequest with 17 keypoints
- AVCaptureSession for camera at 30fps
- Core ML for custom pose analysis models
- Haptic Engine (UIFeedbackGenerator) for tactile feedback
- ARKit depth API for 3D validation (if available)
- Metal shader for efficient frame processing

**Implementation Steps**:
1. Create FlutterMethodChannel handler in AppDelegate
2. Setup AVCaptureSession with 30fps video output
3. Create VNDetectHumanBodyPoseRequest handler
4. Process CVPixelBuffers in background queue
5. Map Vision keypoints to common landmark names
6. Stream pose data via FlutterEventChannel
7. Implement UIImpactFeedbackGenerator patterns
8. Monitor performance with CADisplayLink

## Database Schema Updates

Add to `database_service.dart`:

```sql
CREATE TABLE workout_sessions (
  id TEXT PRIMARY KEY,
  workoutType TEXT NOT NULL,
  level TEXT NOT NULL,
  startTime TEXT NOT NULL,
  endTime TEXT,
  setsData TEXT NOT NULL, -- JSON
  configData TEXT NOT NULL, -- JSON
  completed INTEGER NOT NULL DEFAULT 0,
  notes TEXT,
  createdAt TEXT NOT NULL
);

CREATE INDEX idx_workout_type ON workout_sessions (workoutType, startTime DESC);
CREATE INDEX idx_workout_date ON workout_sessions (startTime DESC);

CREATE TABLE workout_program (
  id TEXT PRIMARY KEY,
  workoutLevels TEXT NOT NULL, -- JSON map
  personalRecords TEXT NOT NULL, -- JSON map
  workoutStreaks TEXT NOT NULL, -- JSON map
  programStartDate TEXT NOT NULL,
  updatedAt TEXT NOT NULL
);
```

## Next Steps - Required Implementation

### 1. Workout Provider (`lib/providers/workout_provider.dart`)
Create state management for workout sessions:
- Active session tracking (current set, current rep)
- Real-time rep counting with pose stream integration
- Form feedback delivery
- Session persistence
- Progress tracking and PR detection
- Rest timer management

### 2. Workout Selection Screen
- Grid of 4 workout cards with looksmaxxing benefits
- Difficulty level selector
- "Start Workout" CTA with safety disclaimers
- Tutorial video access
- Progress stats preview

### 3. Workout Active Screen
- Camera feed with skeleton overlay
- Real-time rep counter (large, prominent)
- Set tracker with progress bar
- Form quality indicator (color-coded joints)
- Form feedback messages
- Rest timer between sets
- Pause/Resume/End workout controls
- Performance FPS indicator

### 4. Workout Complete Screen
- Session summary with form quality scores
- PR achievements highlighted
- Progress comparison to baseline
- Share workout accomplishment
- Next workout recommendation

### 5. Dashboard Integration
- "Workouts" tab in bottom navigation
- Weekly workout calendar
- Volume graphs (reps over time per exercise)
- Streak tracker
- Correlation with facial analysis improvements
- Quick-start buttons

### 6. Tutorial System
- In-app video guides (not YouTube links)
- Common mistakes illustrations
- Proper form demonstrations
- Phone positioning guides
- Safety warnings emphasized

## Performance Targets

### Motion Detection Accuracy
- **Goal**: >95% rep counting accuracy
- **Method**: User testing with manual rep counting comparison
- **Validation**: Form validation catches common mistakes

### Performance Requirements
- ✅ 30fps pose tracking minimum
- ✅ <50ms latency from movement to feedback
- ✅ <5% battery drain per 30-minute session
- ✅ <100MB memory usage during tracking
- ✅ Works on iPhone 8+ / Android SDK 21+

### User Experience
- Skeleton overlay updates smoothly (no lag)
- Audio feedback confirms valid reps
- Haptic feedback feels responsive
- Form corrections helpful, not annoying
- Workouts integrate seamlessly with app

## Safety Features

### Critical Implementations
1. **Neck Curls**: Maximum safety warnings, speed enforcement
2. **All Workouts**: Progressive overload prevents overtraining
3. **Form Validation**: Rejects reps that could cause injury
4. **Rest Periods**: Enforced 60-90 second breaks between sets
5. **Weekly Volume**: Track total workload, suggest rest days

### User Education
- Tutorial videos before first workout
- Safety disclaimers on high-risk exercises
- Injury prevention tips in app
- Form quality feedback teaches proper technique
- Progressive difficulty prevents jumping ahead

## Testing Checklist

- [ ] Mock pose detection works without native code
- [ ] Rep detectors accurately count reps in mock mode
- [ ] Form validation triggers on bad form simulation
- [ ] Database saves/loads workout sessions
- [ ] UI renders at 60fps with pose overlay
- [ ] Rest timers work correctly
- [ ] Progress graphs display accurately
- [ ] Native Android ML Kit integration complete
- [ ] Native iOS Vision integration complete
- [ ] Haptic feedback works on both platforms
- [ ] Battery drain within acceptable range
- [ ] Memory usage stays under 100MB
- [ ] User testing confirms >95% accuracy
- [ ] Safety features prevent risky movements

## Success Metrics

### Quantitative
- Motion detection accuracy >95%
- User retention: Users complete workout at least 2x/week
- Technical performance meets all targets
- No crash reports during workouts

### Qualitative
- Users report workouts "actually help" with posture
- Form feedback improves technique over time
- Integration feels cohesive, not bolted-on
- Safety features appreciated, not intrusive

## Development Priority

1. **Ship First**: Chin Tucks (simplest, highest impact)
   - Complete native pose detection for head tracking only
   - Simplified UI focusing on hold timer
   - Validate with user testing

2. **Second**: Push-Ups (complex but valuable)
   - Full body tracking required
   - Form validation critical for safety

3. **Third**: Face Pulls + Neck Curls
   - Complete the suite
   - Emphasize safety features

## Notes

- All workout models follow evidence-based protocols
- Progressive overload prevents plateaus and overtraining
- Form quality emphasis over rep quantity
- Looksmaxxing benefits clearly communicated
- Safety is paramount, especially for neck exercises
