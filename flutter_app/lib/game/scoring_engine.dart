import '../data/models/app_state_model.dart';
import '../core/constants/app_constants.dart';

/// Progress scoring engine
/// Matches the original React app's scoring.js functionality
class ScoringEngine {
  /// Calculate overall progress score
  static double calculateProgressScore(AppStateModel state) {
    if (!_meetsUnlockRequirements(state)) {
      return 0;
    }

    final consistencyScore = _calculateConsistencyScore(state);
    final challengeScore = _calculateChallengeScore(state);
    final qualityScore = _calculatePhotoQualityScore(state);
    final improvementScore = _calculateImprovementScore(state);

    return consistencyScore * AppConstants.consistencyWeight +
        challengeScore * AppConstants.challengeCompletionWeight +
        qualityScore * AppConstants.photoQualityWeight +
        improvementScore * AppConstants.improvementWeight;
  }

  /// Check if progress score unlock requirements are met
  static bool _meetsUnlockRequirements(AppStateModel state) {
    return state.daysSinceStart >= AppConstants.minDaysForProgress &&
        state.timeline.length >= AppConstants.minPhotosForProgress &&
        state.challenges.length >= AppConstants.minChallengesForProgress;
  }

  /// Calculate consistency score (0-100)
  /// Based on regularity of photo captures
  static double _calculateConsistencyScore(AppStateModel state) {
    if (state.timeline.isEmpty) return 0;

    final totalDays = state.daysSinceStart;
    if (totalDays == 0) return 0;

    // Calculate capture frequency
    final captureRate = state.uniqueDaysWithPhotos / totalDays;

    // Ideal is capturing every 2-3 days
    // Perfect score for capturing every other day or more
    if (captureRate >= 0.5) return 100;
    if (captureRate >= 0.3) return 70 + (captureRate - 0.3) / 0.2 * 30;
    if (captureRate >= 0.15) return 40 + (captureRate - 0.15) / 0.15 * 30;
    return captureRate / 0.15 * 40;
  }

  /// Calculate challenge completion score (0-100)
  static double _calculateChallengeScore(AppStateModel state) {
    if (state.challenges.isEmpty) return 0;

    final totalDays = state.daysSinceStart;
    if (totalDays == 0) return 0;

    // Calculate completion rate
    final completionRate = state.challenges.length / totalDays;

    // Perfect score for completing one challenge per day
    if (completionRate >= 1) return 100;
    return completionRate * 100;
  }

  /// Calculate photo quality score (0-100)
  /// Based on average confidence of timeline entries
  static double _calculatePhotoQualityScore(AppStateModel state) {
    if (state.timeline.isEmpty) return 0;

    final totalConfidence = state.timeline
        .map((e) => e.confidence)
        .reduce((a, b) => a + b);

    return totalConfidence / state.timeline.length;
  }

  /// Calculate improvement score (0-100)
  /// Based on metric trends over time
  static double _calculateImprovementScore(AppStateModel state) {
    if (state.timeline.length < 3) return 50; // Neutral if not enough data

    // Compare recent metrics to older metrics
    final recentEntries = state.timeline.take(3).toList();
    final olderEntries = state.timeline.skip(3).take(3).toList();

    if (olderEntries.isEmpty) return 50;

    double improvementSum = 0;
    int metricCount = 0;

    // Compare each metric
    for (final metricId in recentEntries.first.metrics.keys) {
      final recentAvg = _averageMetricValue(recentEntries, metricId);
      final olderAvg = _averageMetricValue(olderEntries, metricId);

      if (recentAvg != null && olderAvg != null) {
        final change = recentAvg - olderAvg;
        // Normalize change to -50 to +50 range
        improvementSum += (change / 2).clamp(-50, 50);
        metricCount++;
      }
    }

    if (metricCount == 0) return 50;

    // Convert to 0-100 scale (50 is neutral)
    return 50 + (improvementSum / metricCount);
  }

  static double? _averageMetricValue(
    List<TimelineEntry> entries,
    String metricId,
  ) {
    final values = entries
        .where((e) => e.metrics.containsKey(metricId))
        .map((e) => e.metrics[metricId]!.value)
        .toList();

    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Get progress level based on score
  static ProgressLevel getProgressLevel(double score) {
    if (score >= 90) return ProgressLevel.elite;
    if (score >= 75) return ProgressLevel.advanced;
    if (score >= 50) return ProgressLevel.intermediate;
    if (score >= 25) return ProgressLevel.beginner;
    return ProgressLevel.starter;
  }

  /// Calculate days until progress unlocks
  static int daysUntilUnlock(AppStateModel state) {
    final daysRemaining =
        AppConstants.minDaysForProgress - state.daysSinceStart;
    return daysRemaining > 0 ? daysRemaining : 0;
  }

  /// Get unlock status message
  static String getUnlockStatusMessage(AppStateModel state) {
    final daysMet = state.daysSinceStart >= AppConstants.minDaysForProgress;
    final photosMet =
        state.timeline.length >= AppConstants.minPhotosForProgress;
    final challengesMet =
        state.challenges.length >= AppConstants.minChallengesForProgress;

    if (daysMet && photosMet && challengesMet) {
      return 'Progress score unlocked!';
    }

    final missing = <String>[];
    if (!daysMet) {
      missing.add(
          '${AppConstants.minDaysForProgress - state.daysSinceStart} more days');
    }
    if (!photosMet) {
      missing.add(
          '${AppConstants.minPhotosForProgress - state.timeline.length} more photos');
    }
    if (!challengesMet) {
      missing.add(
          '${AppConstants.minChallengesForProgress - state.challenges.length} more challenges');
    }

    return 'Need ${missing.join(", ")} to unlock';
  }
}

/// Progress levels
enum ProgressLevel {
  starter,
  beginner,
  intermediate,
  advanced,
  elite,
}

extension ProgressLevelExtension on ProgressLevel {
  String get label {
    switch (this) {
      case ProgressLevel.starter:
        return 'Starter';
      case ProgressLevel.beginner:
        return 'Beginner';
      case ProgressLevel.intermediate:
        return 'Intermediate';
      case ProgressLevel.advanced:
        return 'Advanced';
      case ProgressLevel.elite:
        return 'Elite';
    }
  }

  int get minScore {
    switch (this) {
      case ProgressLevel.starter:
        return 0;
      case ProgressLevel.beginner:
        return 25;
      case ProgressLevel.intermediate:
        return 50;
      case ProgressLevel.advanced:
        return 75;
      case ProgressLevel.elite:
        return 90;
    }
  }
}
