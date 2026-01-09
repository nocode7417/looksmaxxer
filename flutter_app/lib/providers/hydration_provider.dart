import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/hydration_model.dart';
import '../data/services/database_service.dart';
import 'app_state_provider.dart';

/// Hydration state
class HydrationState {
  final HydrationGoal? goal;
  final HydrationDay? today;
  final List<HydrationDay> weekHistory;
  final HydrationStreak streak;
  final bool isLoading;
  final String? error;

  const HydrationState({
    this.goal,
    this.today,
    this.weekHistory = const [],
    this.streak = const HydrationStreak(currentStreak: 0, longestStreak: 0),
    this.isLoading = false,
    this.error,
  });

  HydrationState copyWith({
    HydrationGoal? goal,
    HydrationDay? today,
    List<HydrationDay>? weekHistory,
    HydrationStreak? streak,
    bool? isLoading,
    String? error,
  }) {
    return HydrationState(
      goal: goal ?? this.goal,
      today: today ?? this.today,
      weekHistory: weekHistory ?? this.weekHistory,
      streak: streak ?? this.streak,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Progress percentage for today (0.0 to 1.0)
  double get todayProgress => today?.progressPercentage ?? 0.0;

  /// Whether goal is reached today
  bool get goalReachedToday => today?.goalReached ?? false;

  /// Current goal amount
  int get goalMl => goal?.goalMl ?? 2500;

  /// Current intake today
  int get todayIntakeMl => today?.totalMl ?? 0;

  /// Remaining ml today
  int get remainingMl => today?.remainingMl ?? goalMl;
}

/// Hydration notifier
class HydrationNotifier extends StateNotifier<HydrationState> {
  final DatabaseService _databaseService;

  HydrationNotifier(this._databaseService) : super(const HydrationState());

  /// Initialize hydration state
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load goal
      final goal = await _databaseService.getCurrentHydrationGoal();

      // Load today's logs
      final todayLogs = await _databaseService.getTodayHydrationLogs();

      // Load week history for streak calculation
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final weekLogs = await _databaseService.getHydrationLogsInRange(
        weekAgo,
        now,
      );

      // Calculate today's data
      final effectiveGoal = goal ?? HydrationGoal.defaultGoal();
      final today = HydrationDay.fromLogs(
        date: now,
        logs: todayLogs,
        goalMl: effectiveGoal.goalMl,
      );

      // Build week history
      final weekHistory = _buildWeekHistory(weekLogs, effectiveGoal.goalMl);

      // Calculate streak
      final streak = HydrationStreak.fromHistory(weekHistory);

      state = state.copyWith(
        goal: effectiveGoal,
        today: today,
        weekHistory: weekHistory,
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

  /// Log hydration intake
  Future<void> logHydration(int amountMl, {DrinkType type = DrinkType.water}) async {
    try {
      final log = HydrationLog(
        timestamp: DateTime.now(),
        amountMl: amountMl,
        drinkType: type,
      );

      await _databaseService.saveHydrationLog(log);

      // Refresh state
      await _refreshToday();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Quick log common amounts
  Future<void> logQuickAmount(int amountMl) async {
    await logHydration(amountMl);
  }

  /// Delete a hydration log
  Future<void> deleteLog(String logId) async {
    try {
      await _databaseService.deleteHydrationLog(logId);
      await _refreshToday();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Set hydration goal
  Future<void> setGoal(HydrationGoal goal) async {
    try {
      await _databaseService.saveHydrationGoal(goal);

      // Recalculate today with new goal
      final today = state.today != null
          ? HydrationDay(
              date: state.today!.date,
              totalMl: state.today!.totalMl,
              goalMl: goal.goalMl,
              logs: state.today!.logs,
            )
          : null;

      state = state.copyWith(goal: goal, today: today);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Set default goal
  Future<void> setDefaultGoal() async {
    await setGoal(HydrationGoal.defaultGoal());
  }

  /// Set personalized goal
  Future<void> setPersonalizedGoal({
    required double weightKg,
    required ActivityLevel activityLevel,
  }) async {
    final goal = HydrationGoal.personalized(
      weightKg: weightKg,
      activityLevel: activityLevel,
    );
    await setGoal(goal);
  }

  /// Refresh today's data
  Future<void> _refreshToday() async {
    final todayLogs = await _databaseService.getTodayHydrationLogs();
    final goalMl = state.goal?.goalMl ?? 2500;

    final today = HydrationDay.fromLogs(
      date: DateTime.now(),
      logs: todayLogs,
      goalMl: goalMl,
    );

    // Update week history and streak
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekLogs = await _databaseService.getHydrationLogsInRange(
      weekAgo,
      now,
    );
    final weekHistory = _buildWeekHistory(weekLogs, goalMl);
    final streak = HydrationStreak.fromHistory(weekHistory);

    state = state.copyWith(
      today: today,
      weekHistory: weekHistory,
      streak: streak,
    );
  }

  /// Build week history from logs
  List<HydrationDay> _buildWeekHistory(List<HydrationLog> logs, int goalMl) {
    final now = DateTime.now();
    final days = <HydrationDay>[];

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final day = HydrationDay.fromLogs(
        date: date,
        logs: logs,
        goalMl: goalMl,
      );
      days.add(day);
    }

    return days;
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Hydration provider
final hydrationProvider =
    StateNotifierProvider<HydrationNotifier, HydrationState>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return HydrationNotifier(databaseService);
});

/// Derived providers
final todayHydrationProvider = Provider<HydrationDay?>((ref) {
  return ref.watch(hydrationProvider).today;
});

final hydrationGoalProvider = Provider<HydrationGoal?>((ref) {
  return ref.watch(hydrationProvider).goal;
});

final hydrationProgressProvider = Provider<double>((ref) {
  return ref.watch(hydrationProvider).todayProgress;
});

final hydrationStreakProvider = Provider<int>((ref) {
  return ref.watch(hydrationProvider).streak.currentStreak;
});

final hasReachedHydrationGoalProvider = Provider<bool>((ref) {
  return ref.watch(hydrationProvider).goalReachedToday;
});

final hydrationRemainingProvider = Provider<int>((ref) {
  return ref.watch(hydrationProvider).remainingMl;
});
