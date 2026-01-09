import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chewing_model.dart';
import '../data/services/database_service.dart';
import '../core/constants/app_constants.dart';
import 'app_state_provider.dart';

/// Chewing state
class ChewingState {
  final ChewingSession? activeSession;
  final ChewingDayStats todayStats;
  final ChewingLevel level;
  final int remainingSeconds;
  final bool isPaused;
  final bool showTmjWarning;
  final ChewingStreak streak;
  final List<ChewingDayStats> weekHistory;
  final bool isLoading;
  final String? error;

  ChewingState({
    this.activeSession,
    ChewingDayStats? todayStats,
    this.level = ChewingLevel.beginner,
    this.remainingSeconds = 0,
    this.isPaused = false,
    this.showTmjWarning = false,
    this.streak = const ChewingStreak(currentStreak: 0, longestStreak: 0),
    this.weekHistory = const [],
    this.isLoading = false,
    this.error,
  }) : todayStats = todayStats ??
            ChewingDayStats.empty(
              date: DateTime.now(),
              targetMinutes: level.dailyTargetMinutes,
            );

  ChewingState copyWith({
    ChewingSession? activeSession,
    ChewingDayStats? todayStats,
    ChewingLevel? level,
    int? remainingSeconds,
    bool? isPaused,
    bool? showTmjWarning,
    ChewingStreak? streak,
    List<ChewingDayStats>? weekHistory,
    bool? isLoading,
    String? error,
    bool clearActiveSession = false,
  }) {
    return ChewingState(
      activeSession: clearActiveSession ? null : (activeSession ?? this.activeSession),
      todayStats: todayStats ?? this.todayStats,
      level: level ?? this.level,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isPaused: isPaused ?? this.isPaused,
      showTmjWarning: showTmjWarning ?? this.showTmjWarning,
      streak: streak ?? this.streak,
      weekHistory: weekHistory ?? this.weekHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Whether a session is currently active
  bool get isSessionActive => activeSession != null && !isPaused;

  /// Daily goal progress (0.0 to 1.0)
  double get dailyProgress => todayStats.progress;

  /// Whether daily goal is met
  bool get dailyGoalMet => todayStats.dailyGoalMet;

  /// Total minutes completed today
  int get minutesCompletedToday => todayStats.totalMinutes;

  /// Target minutes for today
  int get targetMinutesToday => level.dailyTargetMinutes;

  /// Remaining minutes to reach goal
  int get remainingMinutesToday => todayStats.remainingMinutes;

  /// Format remaining time as MM:SS
  String get remainingTimeFormatted {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Week stats computed from weekHistory
  ChewingWeekStats? get weekStats {
    if (weekHistory.isEmpty) return null;
    return ChewingWeekStats.fromDailyStats(weekHistory);
  }

  /// Whether timer is running
  bool get isRunning => activeSession != null;

  /// Elapsed seconds in current session
  int get elapsedSeconds =>
      activeSession != null ? targetMinutesToday * 60 - remainingSeconds : 0;

  /// Current target minutes
  int get targetMinutes => level.dailyTargetMinutes;
}

/// Chewing notifier with timer logic
class ChewingNotifier extends StateNotifier<ChewingState> {
  final DatabaseService _databaseService;
  Timer? _timer;

  ChewingNotifier(this._databaseService) : super(ChewingState());

  /// Initialize chewing state
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Check for active session
      final activeSession = await _databaseService.getActiveChewingSession();

      // Load today's sessions
      final todaySessions = await _databaseService.getTodayChewingSessions();

      // Calculate today's stats
      final todayStats = ChewingDayStats.fromSessions(
        date: DateTime.now(),
        sessions: todaySessions,
        targetMinutes: state.level.dailyTargetMinutes,
      );

      // Load week history for streak
      final now = DateTime.now();
      final weekHistory = await _buildWeekHistory();

      // Calculate streak
      final streak = ChewingStreak.fromDailyStats(weekHistory);

      // Check TMJ warning
      final showTmjWarning = todayStats.tmjWarning;

      // Calculate remaining seconds if there's an active session
      int remainingSeconds = 0;
      if (activeSession != null) {
        remainingSeconds = activeSession.remainingSeconds;
        if (remainingSeconds > 0) {
          _startTimer();
        }
      }

      state = state.copyWith(
        activeSession: activeSession,
        todayStats: todayStats,
        remainingSeconds: remainingSeconds,
        showTmjWarning: showTmjWarning,
        streak: streak,
        weekHistory: weekHistory,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Start a new chewing session
  Future<void> startSession({int? targetMinutes}) async {
    if (state.activeSession != null) return;

    try {
      final minutes = targetMinutes ?? state.level.dailyTargetMinutes;
      final session = ChewingSession.start(targetMinutes: minutes);

      await _databaseService.saveChewingSession(session);

      state = state.copyWith(
        activeSession: session,
        remainingSeconds: minutes * 60,
        isPaused: false,
      );

      _startTimer();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Pause the current session
  void pauseSession() {
    if (state.activeSession == null || state.isPaused) return;

    _timer?.cancel();
    state = state.copyWith(isPaused: true);
  }

  /// Resume the current session
  void resumeSession() {
    if (state.activeSession == null || !state.isPaused) return;

    state = state.copyWith(isPaused: false);
    _startTimer();
  }

  /// Complete the current session
  Future<void> completeSession() async {
    if (state.activeSession == null) return;

    try {
      _timer?.cancel();

      final completedSession = state.activeSession!.complete();
      await _databaseService.saveChewingSession(completedSession);

      // Refresh stats
      await _refreshStats();

      state = state.copyWith(
        clearActiveSession: true,
        remainingSeconds: 0,
        isPaused: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Cancel the current session
  Future<void> cancelSession() async {
    if (state.activeSession == null) return;

    try {
      _timer?.cancel();

      final cancelledSession = state.activeSession!.cancel();
      await _databaseService.saveChewingSession(cancelledSession);

      state = state.copyWith(
        clearActiveSession: true,
        remainingSeconds: 0,
        isPaused: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Set chewing level
  Future<void> setLevel(ChewingLevel level) async {
    state = state.copyWith(level: level);
    await _refreshStats();
  }

  /// Start the countdown timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  /// Timer tick
  void _tick() {
    if (state.isPaused) return;

    final newRemaining = state.remainingSeconds - 1;

    if (newRemaining <= 0) {
      // Session complete
      _timer?.cancel();
      completeSession();
    } else {
      state = state.copyWith(remainingSeconds: newRemaining);
    }
  }

  /// Refresh statistics
  Future<void> _refreshStats() async {
    final todaySessions = await _databaseService.getTodayChewingSessions();
    final todayStats = ChewingDayStats.fromSessions(
      date: DateTime.now(),
      sessions: todaySessions,
      targetMinutes: state.level.dailyTargetMinutes,
    );

    final weekHistory = await _buildWeekHistory();
    final streak = ChewingStreak.fromDailyStats(weekHistory);
    final showTmjWarning = todayStats.tmjWarning;

    state = state.copyWith(
      todayStats: todayStats,
      weekHistory: weekHistory,
      streak: streak,
      showTmjWarning: showTmjWarning,
    );
  }

  /// Build week history
  Future<List<ChewingDayStats>> _buildWeekHistory() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final sessions = await _databaseService.getChewingSessionsInRange(
      weekAgo,
      now,
    );

    final days = <ChewingDayStats>[];
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dayStats = ChewingDayStats.fromSessions(
        date: date,
        sessions: sessions,
        targetMinutes: state.level.dailyTargetMinutes,
      );
      days.add(dayStats);
    }

    return days;
  }

  /// Dismiss TMJ warning
  void dismissTmjWarning() {
    state = state.copyWith(showTmjWarning: false);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Chewing provider (aliased for compatibility)
final chewingNotifierProvider =
    StateNotifierProvider<ChewingNotifier, ChewingState>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return ChewingNotifier(databaseService);
});

/// Legacy alias
final chewingProvider = chewingNotifierProvider;

/// Derived providers

/// Today's chewing stats
final todayChewingStatsProvider = Provider<ChewingDayStats?>((ref) {
  return ref.watch(chewingNotifierProvider).todayStats;
});

/// Week chewing stats
final weekChewingStatsProvider = Provider<ChewingWeekStats?>((ref) {
  return ref.watch(chewingNotifierProvider).weekStats;
});
final isChewingActiveProvider = Provider<bool>((ref) {
  return ref.watch(chewingProvider).isSessionActive;
});

final chewingRemainingTimeProvider = Provider<String>((ref) {
  return ref.watch(chewingProvider).remainingTimeFormatted;
});

final chewingProgressProvider = Provider<double>((ref) {
  return ref.watch(chewingProvider).dailyProgress;
});

final chewingMinutesTodayProvider = Provider<int>((ref) {
  return ref.watch(chewingProvider).minutesCompletedToday;
});

final chewingGoalMetProvider = Provider<bool>((ref) {
  return ref.watch(chewingProvider).dailyGoalMet;
});

final chewingStreakProvider = Provider<int>((ref) {
  return ref.watch(chewingProvider).streak.currentStreak;
});

final chewingLevelProvider = Provider<ChewingLevel>((ref) {
  return ref.watch(chewingProvider).level;
});

final showTmjWarningProvider = Provider<bool>((ref) {
  return ref.watch(chewingProvider).showTmjWarning;
});
