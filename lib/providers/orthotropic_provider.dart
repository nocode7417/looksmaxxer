import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/orthotropic_exercise_model.dart';
import '../data/services/database_service.dart';
import '../data/services/preferences_service.dart';
import 'app_state_provider.dart';

/// State for exercise program management
class ExerciseProgramState {
  final ExerciseProgram? program;
  final bool isLoading;
  final String? error;
  final ExerciseSession? activeSession;

  const ExerciseProgramState({
    this.program,
    this.isLoading = false,
    this.error,
    this.activeSession,
  });

  ExerciseProgramState copyWith({
    ExerciseProgram? program,
    bool? isLoading,
    String? error,
    ExerciseSession? activeSession,
    bool clearActiveSession = false,
  }) {
    return ExerciseProgramState(
      program: program ?? this.program,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      activeSession: clearActiveSession ? null : (activeSession ?? this.activeSession),
    );
  }
}

/// Provider for managing user's orthotropic exercise program
class ExerciseProgramNotifier extends StateNotifier<ExerciseProgramState> {
  final DatabaseService _db;
  final PreferencesService _prefs;

  ExerciseProgramNotifier(this._db, this._prefs)
      : super(const ExerciseProgramState()) {
    _loadProgram();
  }

  /// Load user's exercise program from storage
  Future<void> _loadProgram() async {
    state = state.copyWith(isLoading: true);

    try {
      final programData = await _db.getExerciseProgram();
      if (programData != null) {
        final program = ExerciseProgram.fromMap(programData);
        state = state.copyWith(program: program, isLoading: false);
      } else {
        // Create new program with default exercises
        final defaultProgram = _createDefaultProgram();
        await _db.saveExerciseProgram(defaultProgram.toMap());
        state = state.copyWith(program: defaultProgram, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load exercise program: $e',
      );
    }
  }

  /// Create default program with evidence-based exercises
  ExerciseProgram _createDefaultProgram() {
    final evidenceBasedExercises =
        OrthotropicExerciseLibrary.getEvidenceBased();
    return ExerciseProgram(
      activeExerciseIds: evidenceBasedExercises.map((e) => e.id).toList(),
      sessionHistory: [],
      programStartDate: DateTime.now(),
      exerciseStreak: {},
    );
  }

  /// Add exercise to user's active program
  Future<void> addExercise(String exerciseId) async {
    final program = state.program;
    if (program == null) return;

    if (program.activeExerciseIds.contains(exerciseId)) {
      return; // Already added
    }

    final updatedProgram = ExerciseProgram(
      activeExerciseIds: [...program.activeExerciseIds, exerciseId],
      sessionHistory: program.sessionHistory,
      programStartDate: program.programStartDate,
      exerciseStreak: program.exerciseStreak,
    );

    await _saveProgram(updatedProgram);
  }

  /// Remove exercise from user's active program
  Future<void> removeExercise(String exerciseId) async {
    final program = state.program;
    if (program == null) return;

    final updatedProgram = ExerciseProgram(
      activeExerciseIds:
          program.activeExerciseIds.where((id) => id != exerciseId).toList(),
      sessionHistory: program.sessionHistory,
      programStartDate: program.programStartDate,
      exerciseStreak: program.exerciseStreak,
    );

    await _saveProgram(updatedProgram);
  }

  /// Start new exercise session
  void startSession(String exerciseId) {
    final exercise = OrthotropicExerciseLibrary.exercises
        .firstWhere((e) => e.id == exerciseId);

    final session = ExerciseSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      exerciseId: exerciseId,
      startTime: DateTime.now(),
      completedReps: 0,
      targetReps: exercise.recommendedReps,
      completed: false,
    );

    state = state.copyWith(activeSession: session);
  }

  /// Update active session progress
  void updateSessionProgress(int completedReps) {
    final session = state.activeSession;
    if (session == null) return;

    final updatedSession = ExerciseSession(
      id: session.id,
      exerciseId: session.exerciseId,
      startTime: session.startTime,
      endTime: session.endTime,
      completedReps: completedReps,
      targetReps: session.targetReps,
      completed: session.completed,
      userRating: session.userRating,
      notes: session.notes,
    );

    state = state.copyWith(activeSession: updatedSession);
  }

  /// Complete active session
  Future<void> completeSession({
    double? rating,
    String? notes,
  }) async {
    final session = state.activeSession;
    final program = state.program;
    if (session == null || program == null) return;

    final completedSession = ExerciseSession(
      id: session.id,
      exerciseId: session.exerciseId,
      startTime: session.startTime,
      endTime: DateTime.now(),
      completedReps: session.completedReps,
      targetReps: session.targetReps,
      completed: true,
      userRating: rating,
      notes: notes,
    );

    final updatedProgram = program.withNewSession(completedSession);
    await _saveProgram(updatedProgram);

    state = state.copyWith(clearActiveSession: true);
  }

  /// Cancel active session
  void cancelSession() {
    state = state.copyWith(clearActiveSession: true);
  }

  /// Save exercise session without completing it
  Future<void> savePartialSession() async {
    final session = state.activeSession;
    final program = state.program;
    if (session == null || program == null) return;

    final savedSession = ExerciseSession(
      id: session.id,
      exerciseId: session.exerciseId,
      startTime: session.startTime,
      endTime: DateTime.now(),
      completedReps: session.completedReps,
      targetReps: session.targetReps,
      completed: false,
    );

    final updatedProgram = program.withNewSession(savedSession);
    await _saveProgram(updatedProgram);

    state = state.copyWith(clearActiveSession: true);
  }

  /// Get today's completion status for each exercise
  Map<String, bool> getTodayCompletion() {
    final program = state.program;
    if (program == null) return {};

    final todaySessions = program.getTodaySessions();
    final completion = <String, bool>{};

    for (final exerciseId in program.activeExerciseIds) {
      final exercise = OrthotropicExerciseLibrary.exercises
          .firstWhere((e) => e.id == exerciseId);

      final exerciseSessions = todaySessions
          .where((s) => s.exerciseId == exerciseId && s.completed)
          .toList();

      // Check if recommended sets completed
      completion[exerciseId] =
          exerciseSessions.length >= exercise.recommendedSetsPerDay;
    }

    return completion;
  }

  /// Get active exercises
  List<OrthotropicExercise> getActiveExercises() {
    final program = state.program;
    if (program == null) return [];

    return OrthotropicExerciseLibrary.exercises
        .where((e) => program.activeExerciseIds.contains(e.id))
        .toList();
  }

  /// Get exercises available to add
  List<OrthotropicExercise> getAvailableExercises() {
    final program = state.program;
    if (program == null) return OrthotropicExerciseLibrary.exercises;

    return OrthotropicExerciseLibrary.exercises
        .where((e) => !program.activeExerciseIds.contains(e.id))
        .toList();
  }

  /// Save program to storage
  Future<void> _saveProgram(ExerciseProgram program) async {
    try {
      await _db.saveExerciseProgram(program.toMap());
      state = state.copyWith(program: program);
    } catch (e) {
      state = state.copyWith(error: 'Failed to save program: $e');
    }
  }

  /// Get adherence statistics
  Map<String, dynamic> getAdherenceStats({int? lastNDays}) {
    final program = state.program;
    if (program == null) {
      return {
        'overallRate': 0.0,
        'totalSessions': 0,
        'completedSessions': 0,
        'averageDuration': 0,
      };
    }

    final now = DateTime.now();
    final cutoffDate = lastNDays != null
        ? now.subtract(Duration(days: lastNDays))
        : program.programStartDate;

    final recentSessions = program.sessionHistory
        .where((s) => s.startTime.isAfter(cutoffDate))
        .toList();

    final completedSessions =
        recentSessions.where((s) => s.completed).toList();

    final totalDuration = completedSessions.fold<int>(
      0,
      (sum, s) => sum + s.durationSeconds,
    );

    return {
      'overallRate': program.getAdherenceRate(lastNDays: lastNDays),
      'totalSessions': recentSessions.length,
      'completedSessions': completedSessions.length,
      'averageDuration': completedSessions.isEmpty
          ? 0
          : totalDuration ~/ completedSessions.length,
      'longestStreak': program.exerciseStreak.values.isEmpty
          ? 0
          : program.exerciseStreak.values.reduce((a, b) => a > b ? a : b),
    };
  }
}

/// Provider instance
final exerciseProgramProvider =
    StateNotifierProvider<ExerciseProgramNotifier, ExerciseProgramState>(
  (ref) {
    final db = ref.watch(databaseServiceProvider);
    final prefs = ref.watch(preferencesServiceProvider);
    return ExerciseProgramNotifier(db, prefs);
  },
);

/// Convenience provider for active exercises
final activeExercisesProvider = Provider<List<OrthotropicExercise>>((ref) {
  final programState = ref.watch(exerciseProgramProvider);
  final notifier = ref.read(exerciseProgramProvider.notifier);
  return notifier.getActiveExercises();
});

/// Convenience provider for today's completion status
final todayCompletionProvider = Provider<Map<String, bool>>((ref) {
  final notifier = ref.read(exerciseProgramProvider.notifier);
  return notifier.getTodayCompletion();
});

/// Convenience provider for adherence statistics
final adherenceStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.read(exerciseProgramProvider.notifier);
  return notifier.getAdherenceStats(lastNDays: 30);
});
