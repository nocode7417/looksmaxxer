import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/models.dart';
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

  /// Record an analysis session for usage monitoring
  Future<void> recordAnalysisSession({
    String? photoId,
    Duration duration = const Duration(seconds: 3),
  }) async {
    final sessionId = const Uuid().v4();
    final updatedTracker = UsageMonitor.recordSession(
      state.usageTracker,
      sessionId: sessionId,
      photoId: photoId,
      duration: duration,
    );

    state = state.copyWith(usageTracker: updatedTracker);
    await _saveState();
  }

  /// Check if mental health intervention should be shown
  bool shouldShowIntervention() {
    if (!state.settings.showMentalHealthReminders) return false;
    return state.usageTracker.shouldShowIntervention;
  }

  /// Get the appropriate intervention for current usage
  MentalHealthIntervention? getIntervention() {
    if (!shouldShowIntervention()) return null;

    if (state.usageTracker.isLateNight) {
      return MentalHealthRepository.getLateNightIntervention();
    }

    return MentalHealthRepository.getIntervention(state.usageTracker);
  }

  /// Mark intervention as shown
  Future<void> markInterventionShown() async {
    final updatedTracker = state.usageTracker.copyWith(
      lastInterventionShown: DateTime.now(),
    );
    state = state.copyWith(usageTracker: updatedTracker);
    await _saveState();
  }

  /// Dismiss intervention and increment counter
  Future<void> dismissIntervention() async {
    final updatedTracker = state.usageTracker.copyWith(
      lastInterventionShown: DateTime.now(),
      interventionDismissCount: state.usageTracker.interventionDismissCount + 1,
    );
    state = state.copyWith(usageTracker: updatedTracker);
    await _saveState();
  }

  /// Update geometry analysis results
  Future<void> updateGeometryAnalysis(GeometryAnalysisResult analysis) async {
    state = state.copyWith(latestGeometryAnalysis: analysis);
    await _saveState();
  }

  /// Set user age for content filtering
  Future<void> setUserAge(int age) async {
    state = state.copyWith(userAge: age);
    await _saveState();
  }

  /// Get usage flags for display
  List<UsageFlag> getActiveUsageFlags() {
    return state.usageTracker.activeFlags;
  }

  /// Check if parental controls limit is reached
  bool isParentalLimitReached() {
    final controls = state.settings.parentalControls;
    if (!controls.isEnabled) return false;

    if (controls.maxAnalysesPerDay != null) {
      if (state.usageTracker.todayAnalysesCount >= controls.maxAnalysesPerDay!) {
        return true;
      }
    }

    return false;
  }

  /// Update parental controls
  Future<void> updateParentalControls(ParentalControls controls) async {
    final newSettings = state.settings.copyWith(parentalControls: controls);
    state = state.copyWith(settings: newSettings);
    await _saveState();
  }

  /// Toggle wellness mode
  Future<void> toggleWellnessMode(bool enabled) async {
    final newSettings = state.settings.copyWith(wellnessMode: enabled);
    state = state.copyWith(settings: newSettings);
    await _saveState();
  }

  /// Toggle show evidence labels
  Future<void> toggleEvidenceLabels(bool enabled) async {
    final newSettings = state.settings.copyWith(showEvidenceLabels: enabled);
    state = state.copyWith(settings: newSettings);
    await _saveState();
  }

  /// Toggle show cultural disclaimers
  Future<void> toggleCulturalDisclaimers(bool enabled) async {
    final newSettings = state.settings.copyWith(showCulturalDisclaimers: enabled);
    state = state.copyWith(settings: newSettings);
    await _saveState();
  }

  /// Toggle mental health reminders
  Future<void> toggleMentalHealthReminders(bool enabled) async {
    final newSettings = state.settings.copyWith(showMentalHealthReminders: enabled);
    state = state.copyWith(settings: newSettings);
    await _saveState();
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

/// Usage tracker provider
final usageTrackerProvider = Provider<UsageTracker>((ref) {
  return ref.watch(appStateProvider).usageTracker;
});

/// User age provider
final userAgeProvider = Provider<int?>((ref) {
  return ref.watch(appStateProvider).userAge;
});

/// Settings provider
final settingsProvider = Provider<AppSettings>((ref) {
  return ref.watch(appStateProvider).settings;
});

/// Latest geometry analysis provider
final geometryAnalysisProvider = Provider<GeometryAnalysisResult?>((ref) {
  return ref.watch(appStateProvider).latestGeometryAnalysis;
});

/// Recommendations provider
final recommendationsProvider = Provider<List<Recommendation>>((ref) {
  final metrics = ref.watch(currentMetricsProvider);
  final geometryAnalysis = ref.watch(geometryAnalysisProvider);
  final userAge = ref.watch(userAgeProvider);

  return RecommendationEngine.generateRecommendations(
    metrics: metrics,
    geometryAnalysis: geometryAnalysis,
    userAge: userAge,
  );
});

/// Active usage flags provider
final usageFlagsProvider = Provider<List<UsageFlag>>((ref) {
  return ref.watch(usageTrackerProvider).activeFlags;
});

/// Should show intervention provider
final shouldShowInterventionProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  final tracker = ref.watch(usageTrackerProvider);

  if (!settings.showMentalHealthReminders) return false;
  return tracker.shouldShowIntervention;
});

/// Current intervention provider
final currentInterventionProvider = Provider<MentalHealthIntervention?>((ref) {
  final shouldShow = ref.watch(shouldShowInterventionProvider);
  if (!shouldShow) return null;

  final tracker = ref.watch(usageTrackerProvider);
  if (tracker.isLateNight) {
    return MentalHealthRepository.getLateNightIntervention();
  }

  return MentalHealthRepository.getIntervention(tracker);
});
