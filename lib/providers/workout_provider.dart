import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../data/models/workout_model.dart';
import '../data/services/database_service.dart';
import '../services/pose_detection_service.dart';
import '../engine/pose_detection_engine.dart';
import 'app_state_provider.dart';

/// State for workout program
class WorkoutProgramState {
  final WorkoutProgram? program;
  final bool isLoading;
  final String? error;

  const WorkoutProgramState({
    this.program,
    this.isLoading = false,
    this.error,
  });

  WorkoutProgramState copyWith({
    WorkoutProgram? program,
    bool? isLoading,
    String? error,
  }) {
    return WorkoutProgramState(
      program: program ?? this.program,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider for workout program management
class WorkoutProgramNotifier extends StateNotifier<WorkoutProgramState> {
  final DatabaseService _db;

  WorkoutProgramNotifier(this._db) : super(const WorkoutProgramState()) {
    _loadProgram();
  }

  /// Load workout program from storage
  Future<void> _loadProgram() async {
    state = state.copyWith(isLoading: true);

    try {
      final programData = await _db.getWorkoutProgram();
      if (programData != null) {
        final program = WorkoutProgram.fromMap(programData);
        state = state.copyWith(program: program, isLoading: false);
      } else {
        // Create default program
        final defaultProgram = WorkoutProgram.createDefault();
        await _db.saveWorkoutProgram(defaultProgram.toMap());
        state = state.copyWith(program: defaultProgram, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load workout program: $e',
      );
    }
  }

  /// Save program to storage
  Future<void> _saveProgram(WorkoutProgram program) async {
    try {
      await _db.saveWorkoutProgram(program.toMap());
      state = state.copyWith(program: program);
    } catch (e) {
      state = state.copyWith(error: 'Failed to save program: $e');
    }
  }

  /// Update workout level
  Future<void> updateWorkoutLevel(WorkoutType type, FitnessLevel level) async {
    final program = state.program;
    if (program == null) return;

    final updatedLevels = Map<WorkoutType, FitnessLevel>.from(program.workoutLevels);
    updatedLevels[type] = level;

    final updatedProgram = WorkoutProgram(
      workoutLevels: updatedLevels,
      sessionHistory: program.sessionHistory,
      programStartDate: program.programStartDate,
      workoutStreaks: program.workoutStreaks,
      personalRecords: program.personalRecords,
    );

    await _saveProgram(updatedProgram);
  }

  /// Save completed workout session
  Future<void> saveSession(WorkoutSession session) async {
    final program = state.program;
    if (program == null) return;

    // Add to history
    final updatedHistory = [...program.sessionHistory, session];

    // Update streak
    final updatedStreaks = Map<WorkoutType, int>.from(program.workoutStreaks);
    updatedStreaks[session.workoutType] = _calculateStreak(
      session.workoutType,
      updatedHistory,
    );

    // Check for personal record
    final updatedRecords = Map<WorkoutType, WorkoutSession>.from(program.personalRecords);
    final currentPR = updatedRecords[session.workoutType];
    if (currentPR == null || session.totalReps > currentPR.totalReps) {
      updatedRecords[session.workoutType] = session;
    }

    // Check if level should increase (auto-progression)
    final updatedLevels = Map<WorkoutType, FitnessLevel>.from(program.workoutLevels);
    final shouldLevelUp = _shouldLevelUp(session, updatedHistory);
    if (shouldLevelUp) {
      final currentLevel = program.workoutLevels[session.workoutType]!;
      if (currentLevel == FitnessLevel.beginner) {
        updatedLevels[session.workoutType] = FitnessLevel.intermediate;
      } else if (currentLevel == FitnessLevel.intermediate) {
        updatedLevels[session.workoutType] = FitnessLevel.advanced;
      }
    }

    final updatedProgram = WorkoutProgram(
      workoutLevels: updatedLevels,
      sessionHistory: updatedHistory,
      programStartDate: program.programStartDate,
      workoutStreaks: updatedStreaks,
      personalRecords: updatedRecords,
    );

    await _saveProgram(updatedProgram);
    await _db.saveWorkoutSession(session.toMap());
  }

  /// Calculate current streak for workout type
  int _calculateStreak(WorkoutType type, List<WorkoutSession> history) {
    final sessions = history
        .where((s) => s.workoutType == type && s.completed)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (sessions.isEmpty) return 0;

    int streak = 1;
    DateTime lastDate = sessions.first.startTime;

    for (int i = 1; i < sessions.length; i++) {
      final daysDiff = lastDate.difference(sessions[i].startTime).inDays;
      if (daysDiff <= 1) {
        streak++;
        lastDate = sessions[i].startTime;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Check if user should level up based on performance
  bool _shouldLevelUp(WorkoutSession session, List<WorkoutSession> history) {
    // Check if user hit rep cap with excellent form 3 times
    final config = session.config;
    if (session.totalReps < config.repCap) return false;
    if (session.averageFormAccuracy < 0.85) return false;

    final recentSessions = history
        .where((s) =>
            s.workoutType == session.workoutType &&
            s.completed &&
            s.totalReps >= config.repCap &&
            s.averageFormAccuracy >= 0.85)
        .toList();

    return recentSessions.length >= 3;
  }

  /// Get sessions for specific workout
  List<WorkoutSession> getSessionsForWorkout(WorkoutType type) {
    return state.program?.getSessionsForWorkout(type) ?? [];
  }

  /// Get this week's sessions
  List<WorkoutSession> getThisWeekSessions() {
    return state.program?.getThisWeekSessions() ?? [];
  }

  /// Get weekly volume
  int getWeeklyVolume() {
    return state.program?.getWeeklyVolume() ?? 0;
  }

  /// Get consistency rate
  double getConsistencyRate() {
    return state.program?.getConsistencyRate() ?? 0.0;
  }
}

/// State for active workout session
class ActiveWorkoutState {
  final WorkoutSession? session;
  final WorkoutConfig? config;
  final int currentSet;
  final int currentRep;
  final bool isResting;
  final int restTimeRemaining; // seconds
  final RepDetector? repDetector;
  final PoseDetectionService? poseService;
  final bool isPaused;
  final List<String> realtimeFeedback;
  final double currentFormAccuracy;
  final PerformanceMetrics? performanceMetrics;

  const ActiveWorkoutState({
    this.session,
    this.config,
    this.currentSet = 0,
    this.currentRep = 0,
    this.isResting = false,
    this.restTimeRemaining = 0,
    this.repDetector,
    this.poseService,
    this.isPaused = false,
    this.realtimeFeedback = const [],
    this.currentFormAccuracy = 0.0,
    this.performanceMetrics,
  });

  bool get isActive => session != null;
  bool get isSetComplete => currentRep >= (config?.targetReps ?? 0);
  bool get isWorkoutComplete => currentSet >= (config?.targetSets ?? 0);

  ActiveWorkoutState copyWith({
    WorkoutSession? session,
    WorkoutConfig? config,
    int? currentSet,
    int? currentRep,
    bool? isResting,
    int? restTimeRemaining,
    RepDetector? repDetector,
    PoseDetectionService? poseService,
    bool? isPaused,
    List<String>? realtimeFeedback,
    double? currentFormAccuracy,
    PerformanceMetrics? performanceMetrics,
  }) {
    return ActiveWorkoutState(
      session: session ?? this.session,
      config: config ?? this.config,
      currentSet: currentSet ?? this.currentSet,
      currentRep: currentRep ?? this.currentRep,
      isResting: isResting ?? this.isResting,
      restTimeRemaining: restTimeRemaining ?? this.restTimeRemaining,
      repDetector: repDetector ?? this.repDetector,
      poseService: poseService ?? this.poseService,
      isPaused: isPaused ?? this.isPaused,
      realtimeFeedback: realtimeFeedback ?? this.realtimeFeedback,
      currentFormAccuracy: currentFormAccuracy ?? this.currentFormAccuracy,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
    );
  }
}

/// Provider for active workout session
class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState> {
  final DatabaseService _db;
  StreamSubscription<PoseData>? _poseSubscription;
  Timer? _restTimer;
  Timer? _performanceTimer;
  final List<RepData> _currentSetReps = [];

  ActiveWorkoutNotifier(this._db) : super(const ActiveWorkoutState());

  /// Start new workout session
  Future<void> startWorkout({
    required WorkoutType workoutType,
    required FitnessLevel level,
    required CameraDescription camera,
  }) async {
    // Create configuration
    final config = WorkoutConfig.getConfig(workoutType, level);

    // Create session
    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      workoutType: workoutType,
      level: level,
      startTime: DateTime.now(),
      sets: [],
      config: config,
      completed: false,
    );

    // Initialize pose detection (use mock for now)
    final poseService = MockPoseDetectionService();
    await poseService.initialize(camera: camera, targetFps: 30.0);

    // Create rep detector
    final repDetector = RepDetectorFactory.create(workoutType, config);

    state = state.copyWith(
      session: session,
      config: config,
      currentSet: 1,
      currentRep: 0,
      repDetector: repDetector,
      poseService: poseService,
    );

    // Start pose stream
    _startPoseDetection();

    // Start performance monitoring
    _startPerformanceMonitoring();
  }

  /// Start pose detection stream
  void _startPoseDetection() {
    final poseService = state.poseService;
    final repDetector = state.repDetector;
    if (poseService == null || repDetector == null) return;

    _poseSubscription = poseService.getPoseStream().listen((poseData) {
      if (state.isPaused || state.isResting) return;

      // Process pose through rep detector
      final result = repDetector.process(poseData);

      // Update real-time feedback
      final feedback = <String>[];
      if (result.feedback != null) {
        feedback.add(result.feedback!);
      }

      state = state.copyWith(
        currentFormAccuracy: result.formAccuracy,
        realtimeFeedback: feedback,
      );

      // Check if rep completed
      if (result.isValidRep) {
        _onRepCompleted(result);
      }
    });
  }

  /// Handle rep completion
  void _onRepCompleted(RepDetectionResult result) {
    // Create rep data
    final repData = RepData(
      repNumber: state.currentRep + 1,
      timestamp: DateTime.now(),
      formAccuracy: result.formAccuracy,
      isValid: result.isValidRep,
      formFeedback: result.feedback,
      keypoints: result.metrics,
    );

    _currentSetReps.add(repData);

    // Increment rep counter
    final newRepCount = state.currentRep + 1;
    state = state.copyWith(currentRep: newRepCount);

    // Haptic feedback
    state.poseService?.triggerHaptic(type: HapticType.success);

    // Check if set complete
    if (state.isSetComplete) {
      _completeSet();
    }
  }

  /// Complete current set
  void _completeSet() {
    final config = state.config;
    if (config == null) return;

    // Calculate set statistics
    final avgAccuracy = _currentSetReps.isEmpty
        ? 0.0
        : _currentSetReps.map((r) => r.formAccuracy).reduce((a, b) => a + b) /
            _currentSetReps.length;

    final validReps =
        _currentSetReps.where((r) => r.isValid).length;

    // Create set data
    final setData = SetData(
      setNumber: state.currentSet,
      reps: List.from(_currentSetReps),
      startTime: DateTime.now().subtract(
        Duration(
          seconds: _currentSetReps.length * 3, // Estimate
        ),
      ),
      endTime: DateTime.now(),
      averageFormAccuracy: avgAccuracy,
      validReps: validReps,
      targetReps: config.targetReps,
    );

    // Add to session
    final session = state.session!;
    final updatedSets = [...session.sets, setData];
    final updatedSession = WorkoutSession(
      id: session.id,
      workoutType: session.workoutType,
      level: session.level,
      startTime: session.startTime,
      endTime: session.endTime,
      sets: updatedSets,
      config: session.config,
      completed: session.completed,
      notes: session.notes,
    );

    state = state.copyWith(session: updatedSession);

    // Clear current set reps
    _currentSetReps.clear();

    // Check if workout complete
    if (state.isWorkoutComplete) {
      _completeWorkout();
    } else {
      // Start rest period
      _startRestPeriod();
    }
  }

  /// Start rest period between sets
  void _startRestPeriod() {
    final config = state.config;
    if (config == null) return;

    state = state.copyWith(
      isResting: true,
      restTimeRemaining: config.restBetweenSets,
      currentSet: state.currentSet + 1,
      currentRep: 0,
    );

    // Reset rep detector
    state.repDetector?.reset();

    // Start countdown timer
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.restTimeRemaining - 1;
      if (remaining <= 0) {
        timer.cancel();
        state = state.copyWith(isResting: false, restTimeRemaining: 0);
        // Haptic to signal rest over
        state.poseService?.triggerHaptic(type: HapticType.medium);
      } else {
        state = state.copyWith(restTimeRemaining: remaining);
      }
    });
  }

  /// Complete workout
  void _completeWorkout() async {
    final session = state.session;
    if (session == null) return;

    // Finalize session
    final completedSession = WorkoutSession(
      id: session.id,
      workoutType: session.workoutType,
      level: session.level,
      startTime: session.startTime,
      endTime: DateTime.now(),
      sets: session.sets,
      config: session.config,
      completed: true,
    );

    // Save to database
    await _db.saveWorkoutSession(completedSession.toMap());

    // Stop pose detection
    await _cleanup();

    state = state.copyWith(session: completedSession);
  }

  /// Pause workout
  void pause() {
    state = state.copyWith(isPaused: true);
    _restTimer?.cancel();
  }

  /// Resume workout
  void resume() {
    state = state.copyWith(isPaused: false);
    if (state.isResting) {
      _startRestPeriod();
    }
  }

  /// End workout early
  Future<void> endWorkout() async {
    await _cleanup();
    state = const ActiveWorkoutState();
  }

  /// Start performance monitoring
  void _startPerformanceMonitoring() {
    _performanceTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      final metrics = await state.poseService?.getPerformanceMetrics();
      if (metrics != null) {
        state = state.copyWith(performanceMetrics: metrics);
      }
    });
  }

  /// Cleanup resources
  Future<void> _cleanup() async {
    await _poseSubscription?.cancel();
    _poseSubscription = null;
    _restTimer?.cancel();
    _restTimer = null;
    _performanceTimer?.cancel();
    _performanceTimer = null;
    await state.poseService?.dispose();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}

/// Provider instances
final workoutProgramProvider =
    StateNotifierProvider<WorkoutProgramNotifier, WorkoutProgramState>(
  (ref) {
    final db = ref.watch(databaseServiceProvider);
    return WorkoutProgramNotifier(db);
  },
);

final activeWorkoutProvider =
    StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState>(
  (ref) {
    final db = ref.watch(databaseServiceProvider);
    return ActiveWorkoutNotifier(db);
  },
);

/// Convenience providers
final weeklyVolumeProvider = Provider<int>((ref) {
  final notifier = ref.read(workoutProgramProvider.notifier);
  return notifier.getWeeklyVolume();
});

final consistencyRateProvider = Provider<double>((ref) {
  final notifier = ref.read(workoutProgramProvider.notifier);
  return notifier.getConsistencyRate();
});
