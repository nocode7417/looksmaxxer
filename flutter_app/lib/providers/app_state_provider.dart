import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/models/chewing_model.dart';
import '../data/services/services.dart';
import '../engine/engine.dart';
import '../game/game.dart';

/// App state notifier
class AppStateNotifier extends StateNotifier<AppStateModel> {
  final PreferencesService _preferencesService;
  final DatabaseService _databaseService;

  AppStateNotifier(this._preferencesService, this._databaseService)
      : super(AppStateModel.initial());

  /// Initialize state from storage
  Future<void> initialize() async {
    final savedState = await _preferencesService.loadAppState();
    state = savedState;
  }

  /// Save current state
  Future<void> _saveState() async {
    await _preferencesService.saveAppState(state);
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    state = state.copyWith(hasCompletedOnboarding: true);
    await _saveState();
  }

  /// Set baseline photo
  Future<void> setBaseline(String photoId, Map<String, MetricValue> metrics) async {
    state = state.copyWith(
      baselinePhotoId: photoId,
      baselineDate: DateTime.now(),
      metrics: metrics,
    );
    await _saveState();
  }

  /// Add timeline entry
  Future<void> addTimelineEntry(TimelineEntry entry) async {
    final newTimeline = [entry, ...state.timeline];
    state = state.copyWith(timeline: newTimeline);
    await _saveState();
  }

  /// Complete a challenge
  Future<void> completeChallenge(String challengeId, String category) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Check if this is a new day for streak
    int newStreak = state.challengeStreak;
    if (state.lastChallengeDate != null) {
      final lastDate = DateTime(
        state.lastChallengeDate!.year,
        state.lastChallengeDate!.month,
        state.lastChallengeDate!.day,
      );
      final daysDiff = today.difference(lastDate).inDays;

      if (daysDiff == 1) {
        newStreak = state.challengeStreak + 1;
      } else if (daysDiff > 1) {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    final newChallenge = CompletedChallenge(
      challengeId: challengeId,
      completedAt: now,
      category: category,
    );

    state = state.copyWith(
      challenges: [...state.challenges, newChallenge],
      challengeStreak: newStreak,
      lastChallengeDate: now,
    );
    await _saveState();
  }

  /// Update metrics
  Future<void> updateMetrics(Map<String, MetricValue> metrics) async {
    state = state.copyWith(metrics: metrics);
    await _saveState();
  }

  /// Update progress score
  Future<void> updateProgressScore() async {
    if (!state.isProgressUnlocked) return;

    final score = ScoringEngine.calculateProgressScore(state);
    state = state.copyWith(
      progressScore: score,
      progressUnlockedAt: state.progressUnlockedAt ?? DateTime.now(),
    );
    await _saveState();
  }

  /// Update settings
  Future<void> updateSettings(AppSettings settings) async {
    state = state.copyWith(settings: settings);
    await _saveState();
  }

  /// Complete hydration setup
  Future<void> completeHydrationSetup() async {
    state = state.copyWith(hasCompletedHydrationSetup: true);
    await _saveState();
  }

  /// Set chewing level
  Future<void> setChewingLevel(ChewingLevel level) async {
    state = state.copyWith(chewingLevel: level);
    await _saveState();
  }

  /// Mark notifications as requested
  Future<void> markNotificationsRequested() async {
    state = state.copyWith(hasRequestedNotifications: true);
    await _saveState();
  }

  /// Reset all data
  Future<void> resetAllData() async {
    await _preferencesService.resetAllData();
    await _databaseService.deleteAllPhotos();
    state = AppStateModel.initial();
  }

  /// Check if user has captured photo today
  bool hasCapturedToday() {
    if (state.timeline.isEmpty) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return state.timeline.any((entry) {
      final entryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      return entryDate.isAtSameMomentAs(today);
    });
  }

  /// Check if user has completed today's challenge
  bool hasCompletedTodaysChallenge() {
    if (state.challenges.isEmpty) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return state.challenges.any((challenge) {
      final challengeDate = DateTime(
        challenge.completedAt.year,
        challenge.completedAt.month,
        challenge.completedAt.day,
      );
      return challengeDate.isAtSameMomentAs(today);
    });
  }

  /// Get today's challenge
  Challenge getTodaysChallenge() {
    return ChallengeRepository.getDailyChallenge(DateTime.now());
  }
}

/// Providers
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppStateModel>((ref) {
  final preferencesService = ref.watch(preferencesServiceProvider);
  final databaseService = ref.watch(databaseServiceProvider);
  return AppStateNotifier(preferencesService, databaseService);
});

/// Derived providers
final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).hasCompletedOnboarding;
});

final isProgressUnlockedProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isProgressUnlocked;
});

final currentMetricsProvider = Provider<Map<String, MetricValue>>((ref) {
  return ref.watch(appStateProvider).metrics;
});

final timelineProvider = Provider<List<TimelineEntry>>((ref) {
  return ref.watch(appStateProvider).timeline;
});

final challengeStreakProvider = Provider<int>((ref) {
  return ref.watch(appStateProvider).challengeStreak;
});

final todaysChallengeProvider = Provider<Challenge>((ref) {
  return ChallengeRepository.getDailyChallenge(DateTime.now());
});

final progressScoreProvider = Provider<double?>((ref) {
  return ref.watch(appStateProvider).progressScore;
});

final hasCompletedHydrationSetupProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).hasCompletedHydrationSetup;
});

final hasRequestedNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).hasRequestedNotifications;
});

final chewingLevelProvider = Provider<ChewingLevel>((ref) {
  return ref.watch(appStateProvider).chewingLevel;
});
