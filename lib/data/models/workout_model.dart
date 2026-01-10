/// Production-grade workout system for looksmaxxing with pose detection
/// Focus: Posture correction and facial aesthetics enhancement

import 'package:flutter/foundation.dart';

/// Workout type enum
enum WorkoutType {
  chinTucks,     // Highest priority - direct jawline impact
  pushUps,       // General physique support
  facePulls,     // Posture correction complement
  neckCurls,     // Neck thickness for jaw proportion
}

extension WorkoutTypeExtension on WorkoutType {
  String get displayName {
    switch (this) {
      case WorkoutType.chinTucks:
        return 'Chin Tucks';
      case WorkoutType.pushUps:
        return 'Push-Ups';
      case WorkoutType.facePulls:
        return 'Face Pulls';
      case WorkoutType.neckCurls:
        return 'Neck Curls';
    }
  }

  String get description {
    switch (this) {
      case WorkoutType.chinTucks:
        return 'Correct forward head posture for enhanced jawline definition';
      case WorkoutType.pushUps:
        return 'Build upper body strength and improve overall posture';
      case WorkoutType.facePulls:
        return 'Strengthen posterior chain for optimal shoulder positioning';
      case WorkoutType.neckCurls:
        return 'Develop neck thickness for improved facial proportions';
    }
  }

  String get looksmaxxingBenefit {
    switch (this) {
      case WorkoutType.chinTucks:
        return 'Directly improves jawline appearance by correcting forward head posture. Most impactful exercise for facial aesthetics.';
      case WorkoutType.pushUps:
        return 'Enhances overall physique which frames the face. Better posture highlights facial features.';
      case WorkoutType.facePulls:
        return 'Pulls shoulders back, opening chest and improving head position. Complements chin tucks perfectly.';
      case WorkoutType.neckCurls:
        return 'Increases neck circumference for better jaw-to-neck proportion. Critical for facial harmony.';
    }
  }

  String get safetyWarning {
    switch (this) {
      case WorkoutType.chinTucks:
        return 'Keep movement horizontal - do not tilt head up or down. Should feel stretch at base of skull.';
      case WorkoutType.pushUps:
        return 'Keep core tight and body straight. Stop if you feel lower back pain.';
      case WorkoutType.facePulls:
        return 'Use light weight and focus on slow, controlled movement. Quality over quantity.';
      case WorkoutType.neckCurls:
        return '⚠️ CRITICAL: Never use heavy weights. Neck injury risk is high. Bodyweight only!';
    }
  }
}

/// Fitness level for progressive overload
enum FitnessLevel {
  beginner,
  intermediate,
  advanced,
}

extension FitnessLevelExtension on FitnessLevel {
  String get label {
    switch (this) {
      case FitnessLevel.beginner:
        return 'Beginner';
      case FitnessLevel.intermediate:
        return 'Intermediate';
      case FitnessLevel.advanced:
        return 'Advanced';
    }
  }
}

/// Form quality score
enum FormQuality {
  excellent,  // >90% accuracy
  good,       // 75-90% accuracy
  fair,       // 60-75% accuracy
  poor,       // <60% accuracy
}

extension FormQualityExtension on FormQuality {
  String get label {
    switch (this) {
      case FormQuality.excellent:
        return 'Excellent';
      case FormQuality.good:
        return 'Good';
      case FormQuality.fair:
        return 'Fair';
      case FormQuality.poor:
        return 'Poor';
    }
  }

  String get emoji {
    switch (this) {
      case FormQuality.excellent:
        return '💪';
      case FormQuality.good:
        return '👍';
      case FormQuality.fair:
        return '👌';
      case FormQuality.poor:
        return '⚠️';
    }
  }

  double get minAccuracy {
    switch (this) {
      case FormQuality.excellent:
        return 0.90;
      case FormQuality.good:
        return 0.75;
      case FormQuality.fair:
        return 0.60;
      case FormQuality.poor:
        return 0.0;
    }
  }

  static FormQuality fromAccuracy(double accuracy) {
    if (accuracy >= 0.90) return FormQuality.excellent;
    if (accuracy >= 0.75) return FormQuality.good;
    if (accuracy >= 0.60) return FormQuality.fair;
    return FormQuality.poor;
  }
}

/// Workout configuration with progressive overload
class WorkoutConfig {
  final WorkoutType type;
  final FitnessLevel level;
  final int targetReps;
  final int targetSets;
  final int holdDurationSeconds; // For isometric exercises like chin tucks
  final int restBetweenSets; // Seconds
  final int repCap; // Maximum reps to prevent overtraining
  final int weeklyRepIncrease; // Progressive overload
  final List<String> formCues; // Real-time coaching cues
  final List<String> commonMistakes; // What to avoid

  const WorkoutConfig({
    required this.type,
    required this.level,
    required this.targetReps,
    required this.targetSets,
    this.holdDurationSeconds = 0,
    this.restBetweenSets = 90,
    required this.repCap,
    required this.weeklyRepIncrease,
    required this.formCues,
    required this.commonMistakes,
  });

  /// Get configuration for specific workout and level
  static WorkoutConfig getConfig(WorkoutType type, FitnessLevel level) {
    switch (type) {
      case WorkoutType.chinTucks:
        return _getChinTucksConfig(level);
      case WorkoutType.pushUps:
        return _getPushUpsConfig(level);
      case WorkoutType.facePulls:
        return _getFacePullsConfig(level);
      case WorkoutType.neckCurls:
        return _getNeckCurlsConfig(level);
    }
  }

  static WorkoutConfig _getChinTucksConfig(FitnessLevel level) {
    switch (level) {
      case FitnessLevel.beginner:
        return WorkoutConfig(
          type: WorkoutType.chinTucks,
          level: level,
          targetReps: 10,
          targetSets: 3,
          holdDurationSeconds: 5,
          repCap: 30,
          weeklyRepIncrease: 2,
          formCues: [
            'Pull chin straight back',
            'Keep eyes forward',
            'Feel stretch at skull base',
            'Ear over shoulder alignment',
            'No head tilting',
          ],
          commonMistakes: [
            'Tilting head up or down',
            'Moving too fast',
            'Shrugging shoulders',
            'Holding breath',
          ],
        );
      case FitnessLevel.intermediate:
        return WorkoutConfig(
          type: WorkoutType.chinTucks,
          level: level,
          targetReps: 15,
          targetSets: 3,
          holdDurationSeconds: 8,
          repCap: 40,
          weeklyRepIncrease: 3,
          formCues: [
            'Pull chin straight back',
            'Keep eyes forward',
            'Feel stretch at skull base',
            'Ear over shoulder alignment',
            'No head tilting',
          ],
          commonMistakes: [
            'Tilting head up or down',
            'Moving too fast',
            'Shrugging shoulders',
            'Holding breath',
          ],
        );
      case FitnessLevel.advanced:
        return WorkoutConfig(
          type: WorkoutType.chinTucks,
          level: level,
          targetReps: 20,
          targetSets: 3,
          holdDurationSeconds: 10,
          repCap: 50,
          weeklyRepIncrease: 3,
          formCues: [
            'Pull chin straight back',
            'Keep eyes forward',
            'Feel stretch at skull base',
            'Ear over shoulder alignment',
            'No head tilting',
          ],
          commonMistakes: [
            'Tilting head up or down',
            'Moving too fast',
            'Shrugging shoulders',
            'Holding breath',
          ],
        );
    }
  }

  static WorkoutConfig _getPushUpsConfig(FitnessLevel level) {
    switch (level) {
      case FitnessLevel.beginner:
        return WorkoutConfig(
          type: WorkoutType.pushUps,
          level: level,
          targetReps: 5,
          targetSets: 3,
          repCap: 50,
          weeklyRepIncrease: 2,
          formCues: [
            'Keep body straight',
            'Core engaged',
            'Elbows at 45 degrees',
            'Chest to ground',
            'Full range of motion',
          ],
          commonMistakes: [
            'Sagging hips',
            'Arching back',
            'Flaring elbows',
            'Partial reps',
          ],
        );
      case FitnessLevel.intermediate:
        return WorkoutConfig(
          type: WorkoutType.pushUps,
          level: level,
          targetReps: 15,
          targetSets: 3,
          repCap: 75,
          weeklyRepIncrease: 3,
          formCues: [
            'Keep body straight',
            'Core engaged',
            'Elbows at 45 degrees',
            'Chest to ground',
            'Full range of motion',
          ],
          commonMistakes: [
            'Sagging hips',
            'Arching back',
            'Flaring elbows',
            'Partial reps',
          ],
        );
      case FitnessLevel.advanced:
        return WorkoutConfig(
          type: WorkoutType.pushUps,
          level: level,
          targetReps: 30,
          targetSets: 3,
          repCap: 100,
          weeklyRepIncrease: 5,
          formCues: [
            'Keep body straight',
            'Core engaged',
            'Elbows at 45 degrees',
            'Chest to ground',
            'Full range of motion',
          ],
          commonMistakes: [
            'Sagging hips',
            'Arching back',
            'Flaring elbows',
            'Partial reps',
          ],
        );
    }
  }

  static WorkoutConfig _getFacePullsConfig(FitnessLevel level) {
    // All levels same reps, focus on quality
    return WorkoutConfig(
      type: WorkoutType.facePulls,
      level: level,
      targetReps: 12,
      targetSets: 3,
      repCap: 25,
      weeklyRepIncrease: 2,
      restBetweenSets: 60,
      formCues: [
        'Slow controlled movement',
        'Pull to face level',
        'Squeeze shoulder blades',
        'Elbows high',
        '2 second hold at peak',
      ],
      commonMistakes: [
        'Moving too fast',
        'Using momentum',
        'Pulling too low',
        'Not retracting shoulders',
      ],
    );
  }

  static WorkoutConfig _getNeckCurlsConfig(FitnessLevel level) {
    // All levels same reps, safety-focused
    return WorkoutConfig(
      type: WorkoutType.neckCurls,
      level: level,
      targetReps: 10,
      targetSets: 3,
      repCap: 30,
      weeklyRepIncrease: 2,
      restBetweenSets: 60,
      formCues: [
        'Slow controlled curl',
        'Chin to chest',
        'Feel neck muscles',
        'No jerking',
        'Breathe steadily',
      ],
      commonMistakes: [
        'Moving too fast (DANGER)',
        'Using weight (NEVER)',
        'Jerky movements',
        'Hyperextending neck',
      ],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'level': level.name,
      'targetReps': targetReps,
      'targetSets': targetSets,
      'holdDurationSeconds': holdDurationSeconds,
      'restBetweenSets': restBetweenSets,
      'repCap': repCap,
      'weeklyRepIncrease': weeklyRepIncrease,
      'formCues': formCues,
      'commonMistakes': commonMistakes,
    };
  }

  factory WorkoutConfig.fromMap(Map<String, dynamic> map) {
    return WorkoutConfig(
      type: WorkoutType.values.firstWhere((e) => e.name == map['type']),
      level: FitnessLevel.values.firstWhere((e) => e.name == map['level']),
      targetReps: map['targetReps'],
      targetSets: map['targetSets'],
      holdDurationSeconds: map['holdDurationSeconds'] ?? 0,
      restBetweenSets: map['restBetweenSets'] ?? 90,
      repCap: map['repCap'],
      weeklyRepIncrease: map['weeklyRepIncrease'],
      formCues: List<String>.from(map['formCues']),
      commonMistakes: List<String>.from(map['commonMistakes']),
    );
  }
}

/// Single rep data with form validation
class RepData {
  final int repNumber;
  final DateTime timestamp;
  final double formAccuracy; // 0.0 - 1.0
  final bool isValid;
  final double? holdDuration; // For isometric holds
  final String? formFeedback; // What went wrong if invalid
  final Map<String, double>? keypoints; // Joint angles for analysis

  const RepData({
    required this.repNumber,
    required this.timestamp,
    required this.formAccuracy,
    required this.isValid,
    this.holdDuration,
    this.formFeedback,
    this.keypoints,
  });

  FormQuality get quality => FormQualityExtension.fromAccuracy(formAccuracy);

  Map<String, dynamic> toMap() {
    return {
      'repNumber': repNumber,
      'timestamp': timestamp.toIso8601String(),
      'formAccuracy': formAccuracy,
      'isValid': isValid,
      'holdDuration': holdDuration,
      'formFeedback': formFeedback,
      'keypoints': keypoints,
    };
  }

  factory RepData.fromMap(Map<String, dynamic> map) {
    return RepData(
      repNumber: map['repNumber'],
      timestamp: DateTime.parse(map['timestamp']),
      formAccuracy: map['formAccuracy'],
      isValid: map['isValid'],
      holdDuration: map['holdDuration'],
      formFeedback: map['formFeedback'],
      keypoints: map['keypoints'] != null
          ? Map<String, double>.from(map['keypoints'])
          : null,
    );
  }
}

/// Single set data
class SetData {
  final int setNumber;
  final List<RepData> reps;
  final DateTime startTime;
  final DateTime? endTime;
  final double averageFormAccuracy;
  final int validReps;
  final int targetReps;

  const SetData({
    required this.setNumber,
    required this.reps,
    required this.startTime,
    this.endTime,
    required this.averageFormAccuracy,
    required this.validReps,
    required this.targetReps,
  });

  bool get isComplete => endTime != null;
  int get durationSeconds =>
      endTime?.difference(startTime).inSeconds ?? 0;
  FormQuality get overallQuality =>
      FormQualityExtension.fromAccuracy(averageFormAccuracy);

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'reps': reps.map((r) => r.toMap()).toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'averageFormAccuracy': averageFormAccuracy,
      'validReps': validReps,
      'targetReps': targetReps,
    };
  }

  factory SetData.fromMap(Map<String, dynamic> map) {
    return SetData(
      setNumber: map['setNumber'],
      reps: (map['reps'] as List).map((r) => RepData.fromMap(r)).toList(),
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      averageFormAccuracy: map['averageFormAccuracy'],
      validReps: map['validReps'],
      targetReps: map['targetReps'],
    );
  }
}

/// Complete workout session
class WorkoutSession {
  final String id;
  final WorkoutType workoutType;
  final FitnessLevel level;
  final DateTime startTime;
  final DateTime? endTime;
  final List<SetData> sets;
  final WorkoutConfig config;
  final bool completed;
  final String? notes;

  const WorkoutSession({
    required this.id,
    required this.workoutType,
    required this.level,
    required this.startTime,
    this.endTime,
    required this.sets,
    required this.config,
    required this.completed,
    this.notes,
  });

  int get totalReps => sets.fold(0, (sum, set) => sum + set.validReps);
  int get totalSets => sets.length;
  double get averageFormAccuracy {
    if (sets.isEmpty) return 0.0;
    final total = sets.fold(0.0, (sum, set) => sum + set.averageFormAccuracy);
    return total / sets.length;
  }

  FormQuality get overallQuality =>
      FormQualityExtension.fromAccuracy(averageFormAccuracy);
  int get durationSeconds =>
      endTime?.difference(startTime).inSeconds ?? 0;

  bool get isPersonalRecord {
    // Check if this session beat previous records
    // Implementation in provider
    return false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workoutType': workoutType.name,
      'level': level.name,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'sets': sets.map((s) => s.toMap()).toList(),
      'config': config.toMap(),
      'completed': completed,
      'notes': notes,
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    return WorkoutSession(
      id: map['id'],
      workoutType:
          WorkoutType.values.firstWhere((e) => e.name == map['workoutType']),
      level: FitnessLevel.values.firstWhere((e) => e.name == map['level']),
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      sets: (map['sets'] as List).map((s) => SetData.fromMap(s)).toList(),
      config: WorkoutConfig.fromMap(map['config']),
      completed: map['completed'],
      notes: map['notes'],
    );
  }
}

/// Workout program tracking user's progress
class WorkoutProgram {
  final Map<WorkoutType, FitnessLevel> workoutLevels;
  final List<WorkoutSession> sessionHistory;
  final DateTime programStartDate;
  final Map<WorkoutType, int> workoutStreaks; // Consecutive days
  final Map<WorkoutType, WorkoutSession> personalRecords; // Best sessions

  const WorkoutProgram({
    required this.workoutLevels,
    required this.sessionHistory,
    required this.programStartDate,
    required this.workoutStreaks,
    required this.personalRecords,
  });

  /// Get sessions for specific workout type
  List<WorkoutSession> getSessionsForWorkout(WorkoutType type) {
    return sessionHistory.where((s) => s.workoutType == type).toList();
  }

  /// Get this week's sessions
  List<WorkoutSession> getThisWeekSessions() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return sessionHistory
        .where((s) => s.startTime.isAfter(weekStart))
        .toList();
  }

  /// Calculate total volume (reps) this week
  int getWeeklyVolume() {
    return getThisWeekSessions()
        .fold(0, (sum, session) => sum + session.totalReps);
  }

  /// Get workout consistency (% of days worked out in last 30 days)
  double getConsistencyRate() {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentSessions =
        sessionHistory.where((s) => s.startTime.isAfter(thirtyDaysAgo));

    // Count unique workout days
    final workoutDays = recentSessions
        .map((s) => DateTime(
            s.startTime.year, s.startTime.month, s.startTime.day))
        .toSet()
        .length;

    return (workoutDays / 30.0) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'workoutLevels': workoutLevels.map((k, v) => MapEntry(k.name, v.name)),
      'sessionHistory': sessionHistory.map((s) => s.toMap()).toList(),
      'programStartDate': programStartDate.toIso8601String(),
      'workoutStreaks': workoutStreaks.map((k, v) => MapEntry(k.name, v)),
      'personalRecords':
          personalRecords.map((k, v) => MapEntry(k.name, v.toMap())),
    };
  }

  factory WorkoutProgram.fromMap(Map<String, dynamic> map) {
    return WorkoutProgram(
      workoutLevels: (map['workoutLevels'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          WorkoutType.values.firstWhere((e) => e.name == k),
          FitnessLevel.values.firstWhere((e) => e.name == v),
        ),
      ),
      sessionHistory: (map['sessionHistory'] as List)
          .map((s) => WorkoutSession.fromMap(s))
          .toList(),
      programStartDate: DateTime.parse(map['programStartDate']),
      workoutStreaks: (map['workoutStreaks'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
            WorkoutType.values.firstWhere((e) => e.name == k), v as int),
      ),
      personalRecords: (map['personalRecords'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(
          WorkoutType.values.firstWhere((e) => e.name == k),
          WorkoutSession.fromMap(v),
        ),
      ),
    );
  }

  /// Create default program
  static WorkoutProgram createDefault() {
    return WorkoutProgram(
      workoutLevels: {
        WorkoutType.chinTucks: FitnessLevel.beginner,
        WorkoutType.pushUps: FitnessLevel.beginner,
        WorkoutType.facePulls: FitnessLevel.beginner,
        WorkoutType.neckCurls: FitnessLevel.beginner,
      },
      sessionHistory: [],
      programStartDate: DateTime.now(),
      workoutStreaks: {},
      personalRecords: {},
    );
  }
}

/// Phone positioning guide for optimal pose detection
class PhonePosition {
  final WorkoutType workoutType;
  final double distanceMeters;
  final double angleDegrees; // 0 = level, 45 = angled down
  final String viewType; // 'profile', 'front', '45-degree'
  final String heightInstruction;

  const PhonePosition({
    required this.workoutType,
    required this.distanceMeters,
    required this.angleDegrees,
    required this.viewType,
    required this.heightInstruction,
  });

  static PhonePosition getPosition(WorkoutType type) {
    switch (type) {
      case WorkoutType.chinTucks:
        return const PhonePosition(
          workoutType: WorkoutType.chinTucks,
          distanceMeters: 1.0,
          angleDegrees: 0,
          viewType: 'profile',
          heightInstruction: 'Position phone at eye level, profile view',
        );
      case WorkoutType.pushUps:
        return const PhonePosition(
          workoutType: WorkoutType.pushUps,
          distanceMeters: 1.5,
          angleDegrees: 45,
          viewType: '45-degree',
          heightInstruction:
              'Position phone 1.5m away, angled down at 45°, side view',
        );
      case WorkoutType.facePulls:
        return const PhonePosition(
          workoutType: WorkoutType.facePulls,
          distanceMeters: 1.2,
          angleDegrees: 0,
          viewType: 'front',
          heightInstruction:
              'Position phone at chest level, front view',
        );
      case WorkoutType.neckCurls:
        return const PhonePosition(
          workoutType: WorkoutType.neckCurls,
          distanceMeters: 1.0,
          angleDegrees: 0,
          viewType: 'profile',
          heightInstruction: 'Position phone at head level, profile view',
        );
    }
  }
}
