import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/mewing_model.dart';
import '../data/services/database_service.dart';
import 'app_state_provider.dart';

/// Mewing state
class MewingState {
  final MewingStreak streak;
  final MewingSession? todaySession;
  final List<MewingSession> monthHistory;
  final MewingMonth? currentMonth;
  final bool isLoading;
  final String? error;
  final StreakMilestone? justAchievedMilestone;

  const MewingState({
    this.streak = const MewingStreak(currentStreak: 0, longestStreak: 0),
    this.todaySession,
    this.monthHistory = const [],
    this.currentMonth,
    this.isLoading = false,
    this.error,
    this.justAchievedMilestone,
  });

  MewingState copyWith({
    MewingStreak? streak,
    MewingSession? todaySession,
    List<MewingSession>? monthHistory,
    MewingMonth? currentMonth,
    bool? isLoading,
    String? error,
    StreakMilestone? justAchievedMilestone,
    bool clearMilestone = false,
  }) {
    return MewingState(
      streak: streak ?? this.streak,
      todaySession: todaySession ?? this.todaySession,
      monthHistory: monthHistory ?? this.monthHistory,
      currentMonth: currentMonth ?? this.currentMonth,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      justAchievedMilestone:
          clearMilestone ? null : (justAchievedMilestone ?? this.justAchievedMilestone),
    );
  }

  /// Whether user has checked in today
  bool get hasCheckedInToday => todaySession?.checkedIn ?? false;

  /// Current streak count
  int get currentStreakDays => streak.currentStreak;

  /// Longest streak count
  int get longestStreakDays => streak.longestStreak;

  /// Progress to next milestone (0.0 to 1.0)
  double get progressToNextMilestone => streak.progressToNextMilestone;

  /// Next milestone to achieve
  StreakMilestone? get nextMilestone => streak.nextMilestone;

  /// Days until next milestone
  int get daysUntilNextMilestone => streak.daysUntilNextMilestone;
}

/// Mewing notifier
class MewingNotifier extends StateNotifier<MewingState> {
  final DatabaseService _databaseService;

  MewingNotifier(this._databaseService) : super(const MewingState());

  /// Initialize mewing state
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load today's session
      final todaySession = await _databaseService.getTodayMewingSession();

      // Load month history
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0);
      final monthSessions = await _databaseService.getMewingSessionsInRange(
        monthStart,
        monthEnd,
      );

      // Load all sessions for streak calculation (last 365 days)
      final yearAgo = now.subtract(const Duration(days: 365));
      final allSessions = await _databaseService.getMewingSessionsInRange(
        yearAgo,
        now,
      );

      // Calculate streak
      final streak = MewingStreak.fromSessions(allSessions);

      // Build current month view
      final currentMonth = MewingMonth.fromSessions(
        year: now.year,
        month: now.month,
        sessions: monthSessions,
      );

      state = state.copyWith(
        todaySession: todaySession,
        monthHistory: monthSessions,
        currentMonth: currentMonth,
        streak: streak,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Check in for today
  Future<void> checkIn({int? durationMinutes, String? notes}) async {
    try {
      final previousStreak = state.streak.currentStreak;

      // Create or update today's session
      final session = state.todaySession?.copyWith(
            checkedIn: true,
            durationMinutes: durationMinutes,
            notes: notes,
          ) ??
          MewingSession.checkInToday(
            durationMinutes: durationMinutes,
            notes: notes,
          );

      await _databaseService.saveMewingSession(session);

      // Refresh state
      await _refreshState();

      // Check if a new milestone was achieved
      final newStreak = state.streak.currentStreak;
      if (newStreak > previousStreak) {
        final achievedMilestone = StreakMilestone.getMilestoneForDays(newStreak);
        if (achievedMilestone != null) {
          state = state.copyWith(
            justAchievedMilestone: achievedMilestone.copyWith(
              achieved: true,
              achievedAt: DateTime.now(),
            ),
          );
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Undo today's check-in (for accidental taps)
  Future<void> undoCheckIn() async {
    if (state.todaySession == null || !state.todaySession!.checkedIn) return;

    try {
      final session = state.todaySession!.copyWith(checkedIn: false);
      await _databaseService.saveMewingSession(session);
      await _refreshState();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load data for a specific month
  Future<MewingMonth> loadMonth(int year, int month) async {
    final monthStart = DateTime(year, month, 1);
    final monthEnd = DateTime(year, month + 1, 0);
    final sessions = await _databaseService.getMewingSessionsInRange(
      monthStart,
      monthEnd,
    );

    return MewingMonth.fromSessions(
      year: year,
      month: month,
      sessions: sessions,
    );
  }

  /// Refresh state
  Future<void> _refreshState() async {
    final now = DateTime.now();

    // Reload today's session
    final todaySession = await _databaseService.getTodayMewingSession();

    // Reload month history
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    final monthSessions = await _databaseService.getMewingSessionsInRange(
      monthStart,
      monthEnd,
    );

    // Reload all sessions for streak
    final yearAgo = now.subtract(const Duration(days: 365));
    final allSessions = await _databaseService.getMewingSessionsInRange(
      yearAgo,
      now,
    );

    // Recalculate streak
    final streak = MewingStreak.fromSessions(allSessions);

    // Rebuild current month
    final currentMonth = MewingMonth.fromSessions(
      year: now.year,
      month: now.month,
      sessions: monthSessions,
    );

    state = state.copyWith(
      todaySession: todaySession,
      monthHistory: monthSessions,
      currentMonth: currentMonth,
      streak: streak,
    );
  }

  /// Clear milestone notification
  void clearMilestoneNotification() {
    state = state.copyWith(clearMilestone: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Mewing provider
final mewingProvider =
    StateNotifierProvider<MewingNotifier, MewingState>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return MewingNotifier(databaseService);
});

/// Derived providers
final hasMewedTodayProvider = Provider<bool>((ref) {
  return ref.watch(mewingProvider).hasCheckedInToday;
});

final mewingStreakProvider = Provider<int>((ref) {
  return ref.watch(mewingProvider).currentStreakDays;
});

final mewingLongestStreakProvider = Provider<int>((ref) {
  return ref.watch(mewingProvider).longestStreakDays;
});

final mewingNextMilestoneProvider = Provider<StreakMilestone?>((ref) {
  return ref.watch(mewingProvider).nextMilestone;
});

final mewingMilestoneProgressProvider = Provider<double>((ref) {
  return ref.watch(mewingProvider).progressToNextMilestone;
});

final mewingCurrentMonthProvider = Provider<MewingMonth?>((ref) {
  return ref.watch(mewingProvider).currentMonth;
});

final mewingJustAchievedMilestoneProvider = Provider<StreakMilestone?>((ref) {
  return ref.watch(mewingProvider).justAchievedMilestone;
});
