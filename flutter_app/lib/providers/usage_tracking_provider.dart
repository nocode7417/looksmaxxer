import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/usage_tracking_model.dart';
import '../data/services/database_service.dart';
import 'app_state_provider.dart';

/// Usage tracking state
class UsageTrackingState {
  final UsageSession? currentSession;
  final UsagePattern pattern;
  final Intervention? pendingIntervention;
  final bool showInterventionDialog;
  final bool isLoading;
  final String? error;

  const UsageTrackingState({
    this.currentSession,
    this.pattern = const UsagePattern(
      dailySessionCount: 0,
      consecutiveDaysActive: 0,
      analysisCountToday: 0,
      analysisCountThisWeek: 0,
      averageSessionDuration: Duration.zero,
    ),
    this.pendingIntervention,
    this.showInterventionDialog = false,
    this.isLoading = false,
    this.error,
  });

  UsageTrackingState copyWith({
    UsageSession? currentSession,
    UsagePattern? pattern,
    Intervention? pendingIntervention,
    bool? showInterventionDialog,
    bool? isLoading,
    String? error,
    bool clearCurrentSession = false,
    bool clearIntervention = false,
  }) {
    return UsageTrackingState(
      currentSession: clearCurrentSession ? null : (currentSession ?? this.currentSession),
      pattern: pattern ?? this.pattern,
      pendingIntervention: clearIntervention ? null : (pendingIntervention ?? this.pendingIntervention),
      showInterventionDialog: showInterventionDialog ?? this.showInterventionDialog,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Check if there's an active alert
  UsageAlertType? get currentAlert => pattern.currentAlert;

  /// Check if approaching daily limit
  bool get isApproachingLimit => pattern.isApproachingDailyLimit;

  /// Remaining analyses today
  int get remainingAnalyses => pattern.remainingAnalysesToday;

  /// Analysis count today
  int get analysisCountToday => pattern.analysisCountToday;

  /// Whether user should be warned
  bool get shouldShowWarning => currentAlert != null && !showInterventionDialog;
}

/// Usage tracking notifier
class UsageTrackingNotifier extends StateNotifier<UsageTrackingState> {
  final DatabaseService _databaseService;

  UsageTrackingNotifier(this._databaseService) : super(const UsageTrackingState());

  /// Initialize usage tracking
  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load recent sessions
      final sessions = await _databaseService.getRecentUsageSessions();

      // Calculate pattern
      final pattern = UsagePattern.fromSessions(sessions);

      // Check for pending intervention
      final alert = pattern.currentAlert;
      Intervention? pendingIntervention;
      bool showDialog = false;

      if (alert != null) {
        // Check if we recently showed an intervention
        final lastIntervention = await _databaseService.getMostRecentIntervention();
        final now = DateTime.now();

        // Only show intervention if last one was > 1 hour ago
        if (lastIntervention == null ||
            now.difference(lastIntervention.triggeredAt).inHours >= 1) {
          pendingIntervention = Intervention(
            triggeredAt: now,
            triggerType: alert,
          );
          showDialog = true;
        }
      }

      state = state.copyWith(
        pattern: pattern,
        pendingIntervention: pendingIntervention,
        showInterventionDialog: showDialog,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Start a new usage session
  Future<void> startSession(ScreenType screenType) async {
    try {
      // End any existing session
      if (state.currentSession != null) {
        await endSession();
      }

      final session = UsageSession.start(screenType);
      await _databaseService.saveUsageSession(session);

      state = state.copyWith(currentSession: session);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// End the current session
  Future<void> endSession() async {
    if (state.currentSession == null) return;

    try {
      final endedSession = state.currentSession!.end();
      await _databaseService.saveUsageSession(endedSession);

      state = state.copyWith(clearCurrentSession: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Track an analysis event
  Future<void> trackAnalysis() async {
    try {
      // Update current session's analysis count
      if (state.currentSession != null) {
        final updatedSession = state.currentSession!.incrementAnalysis();
        await _databaseService.saveUsageSession(updatedSession);
        state = state.copyWith(currentSession: updatedSession);
      }

      // Refresh pattern to check for alerts
      await _refreshPattern();

      // Check if we should show intervention
      final alert = state.pattern.currentAlert;
      if (alert != null && !state.showInterventionDialog) {
        final lastIntervention = await _databaseService.getMostRecentIntervention();
        final now = DateTime.now();

        // Only show if last one was > 1 hour ago
        if (lastIntervention == null ||
            now.difference(lastIntervention.triggeredAt).inHours >= 1) {
          final intervention = Intervention(
            triggeredAt: now,
            triggerType: alert,
          );

          await _databaseService.saveIntervention(intervention);

          state = state.copyWith(
            pendingIntervention: intervention,
            showInterventionDialog: true,
          );
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Track an interaction event
  Future<void> trackInteraction() async {
    if (state.currentSession == null) return;

    try {
      final updatedSession = state.currentSession!.incrementInteraction();
      await _databaseService.saveUsageSession(updatedSession);
      state = state.copyWith(currentSession: updatedSession);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Acknowledge an intervention
  Future<void> acknowledgeIntervention(InterventionResponse response) async {
    if (state.pendingIntervention == null) return;

    try {
      final acknowledged = state.pendingIntervention!.acknowledge(response);
      await _databaseService.saveIntervention(acknowledged);

      state = state.copyWith(
        clearIntervention: true,
        showInterventionDialog: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Dismiss intervention dialog (without response)
  void dismissInterventionDialog() {
    state = state.copyWith(showInterventionDialog: false);
  }

  /// Refresh usage pattern
  Future<void> _refreshPattern() async {
    final sessions = await _databaseService.getRecentUsageSessions();
    final pattern = UsagePattern.fromSessions(sessions);
    state = state.copyWith(pattern: pattern);
  }

  /// Check if analysis should be allowed
  bool canPerformAnalysis() {
    return state.remainingAnalyses > 0;
  }

  /// Get warning message for user
  String? getWarningMessage() {
    final alert = state.currentAlert;
    if (alert == null) return null;
    return alert.message;
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Usage tracking provider (aliased for compatibility)
final usageTrackingNotifierProvider =
    StateNotifierProvider<UsageTrackingNotifier, UsageTrackingState>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return UsageTrackingNotifier(databaseService);
});

/// Legacy alias
final usageTrackingProvider = usageTrackingNotifierProvider;

/// Derived providers
final shouldShowInterventionProvider = Provider<bool>((ref) {
  return ref.watch(usageTrackingProvider).showInterventionDialog;
});

final currentInterventionProvider = Provider<Intervention?>((ref) {
  return ref.watch(usageTrackingProvider).pendingIntervention;
});

final remainingAnalysesProvider = Provider<int>((ref) {
  return ref.watch(usageTrackingProvider).remainingAnalyses;
});

final analysisCountTodayProvider = Provider<int>((ref) {
  return ref.watch(usageTrackingProvider).analysisCountToday;
});

final isApproachingLimitProvider = Provider<bool>((ref) {
  return ref.watch(usageTrackingProvider).isApproachingLimit;
});

final canPerformAnalysisProvider = Provider<bool>((ref) {
  return ref.watch(usageTrackingProvider).remainingAnalyses > 0;
});

/// Crisis resources provider (static)
final crisisResourcesProvider = Provider<List<CrisisResource>>((ref) {
  return CrisisResource.allResources;
});
