import 'dart:convert';
import 'photo_model.dart';
import 'chewing_model.dart';

/// Main app state model
class AppStateModel {
  final bool hasCompletedOnboarding;
  final bool hasCompletedHydrationSetup;
  final bool hasRequestedNotifications;
  final String? baselinePhotoId;
  final DateTime? baselineDate;
  final Map<String, MetricValue> metrics;
  final List<TimelineEntry> timeline;
  final List<CompletedChallenge> challenges;
  final int challengeStreak;
  final DateTime? lastChallengeDate;
  final double? progressScore;
  final DateTime? progressUnlockedAt;
  final ChewingLevel chewingLevel;
  final AppSettings settings;
  final DateTime createdAt;

  AppStateModel({
    this.hasCompletedOnboarding = false,
    this.hasCompletedHydrationSetup = false,
    this.hasRequestedNotifications = false,
    this.baselinePhotoId,
    this.baselineDate,
    this.metrics = const {},
    this.timeline = const [],
    this.challenges = const [],
    this.challengeStreak = 0,
    this.lastChallengeDate,
    this.progressScore,
    this.progressUnlockedAt,
    this.chewingLevel = ChewingLevel.beginner,
    AppSettings? settings,
    DateTime? createdAt,
  })  : settings = settings ?? AppSettings(),
        createdAt = createdAt ?? DateTime.now();

  /// Create initial state
  factory AppStateModel.initial() {
    return AppStateModel(createdAt: DateTime.now());
  }

  /// Convert to JSON string for storage
  String toJson() {
    return jsonEncode({
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'hasCompletedHydrationSetup': hasCompletedHydrationSetup,
      'hasRequestedNotifications': hasRequestedNotifications,
      'baselinePhotoId': baselinePhotoId,
      'baselineDate': baselineDate?.toIso8601String(),
      'metrics': metrics.map((k, v) => MapEntry(k, v.toMap())),
      'timeline': timeline.map((e) => e.toMap()).toList(),
      'challenges': challenges.map((e) => e.toMap()).toList(),
      'challengeStreak': challengeStreak,
      'lastChallengeDate': lastChallengeDate?.toIso8601String(),
      'progressScore': progressScore,
      'progressUnlockedAt': progressUnlockedAt?.toIso8601String(),
      'chewingLevel': chewingLevel.name,
      'settings': settings.toMap(),
      'createdAt': createdAt.toIso8601String(),
    });
  }

  /// Create from JSON string
  factory AppStateModel.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return AppStateModel(
      hasCompletedOnboarding: map['hasCompletedOnboarding'] ?? false,
      hasCompletedHydrationSetup: map['hasCompletedHydrationSetup'] ?? false,
      hasRequestedNotifications: map['hasRequestedNotifications'] ?? false,
      baselinePhotoId: map['baselinePhotoId'],
      baselineDate: map['baselineDate'] != null
          ? DateTime.parse(map['baselineDate'])
          : null,
      metrics: (map['metrics'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, MetricValue.fromMap(v)),
          ) ??
          {},
      timeline: (map['timeline'] as List<dynamic>?)
              ?.map((e) => TimelineEntry.fromMap(e))
              .toList() ??
          [],
      challenges: (map['challenges'] as List<dynamic>?)
              ?.map((e) => CompletedChallenge.fromMap(e))
              .toList() ??
          [],
      challengeStreak: map['challengeStreak'] ?? 0,
      lastChallengeDate: map['lastChallengeDate'] != null
          ? DateTime.parse(map['lastChallengeDate'])
          : null,
      progressScore: map['progressScore']?.toDouble(),
      progressUnlockedAt: map['progressUnlockedAt'] != null
          ? DateTime.parse(map['progressUnlockedAt'])
          : null,
      chewingLevel: map['chewingLevel'] != null
          ? ChewingLevel.values.firstWhere(
              (l) => l.name == map['chewingLevel'],
              orElse: () => ChewingLevel.beginner,
            )
          : ChewingLevel.beginner,
      settings: map['settings'] != null
          ? AppSettings.fromMap(map['settings'])
          : AppSettings(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  AppStateModel copyWith({
    bool? hasCompletedOnboarding,
    bool? hasCompletedHydrationSetup,
    bool? hasRequestedNotifications,
    String? baselinePhotoId,
    DateTime? baselineDate,
    Map<String, MetricValue>? metrics,
    List<TimelineEntry>? timeline,
    List<CompletedChallenge>? challenges,
    int? challengeStreak,
    DateTime? lastChallengeDate,
    double? progressScore,
    DateTime? progressUnlockedAt,
    ChewingLevel? chewingLevel,
    AppSettings? settings,
    DateTime? createdAt,
  }) {
    return AppStateModel(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      hasCompletedHydrationSetup:
          hasCompletedHydrationSetup ?? this.hasCompletedHydrationSetup,
      hasRequestedNotifications:
          hasRequestedNotifications ?? this.hasRequestedNotifications,
      baselinePhotoId: baselinePhotoId ?? this.baselinePhotoId,
      baselineDate: baselineDate ?? this.baselineDate,
      metrics: metrics ?? this.metrics,
      timeline: timeline ?? this.timeline,
      challenges: challenges ?? this.challenges,
      challengeStreak: challengeStreak ?? this.challengeStreak,
      lastChallengeDate: lastChallengeDate ?? this.lastChallengeDate,
      progressScore: progressScore ?? this.progressScore,
      progressUnlockedAt: progressUnlockedAt ?? this.progressUnlockedAt,
      chewingLevel: chewingLevel ?? this.chewingLevel,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Days since app started
  int get daysSinceStart {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// Total unique days with photos
  int get uniqueDaysWithPhotos {
    final uniqueDays = <String>{};
    for (final entry in timeline) {
      final dateKey =
          '${entry.date.year}-${entry.date.month}-${entry.date.day}';
      uniqueDays.add(dateKey);
    }
    return uniqueDays.length;
  }

  /// Check if progress score is unlocked
  bool get isProgressUnlocked {
    return daysSinceStart >= 14 &&
        timeline.length >= 7 &&
        challenges.length >= 5;
  }

  /// Average confidence across all metrics
  double get averageConfidence {
    if (metrics.isEmpty) return 0;
    return metrics.values.map((m) => m.confidence).reduce((a, b) => a + b) /
        metrics.length;
  }
}

/// Timeline entry for a photo capture
class TimelineEntry {
  final String photoId;
  final DateTime date;
  final double confidence;
  final Map<String, MetricValue> metrics;

  TimelineEntry({
    required this.photoId,
    required this.date,
    required this.confidence,
    required this.metrics,
  });

  Map<String, dynamic> toMap() {
    return {
      'photoId': photoId,
      'date': date.toIso8601String(),
      'confidence': confidence,
      'metrics': metrics.map((k, v) => MapEntry(k, v.toMap())),
    };
  }

  factory TimelineEntry.fromMap(Map<String, dynamic> map) {
    return TimelineEntry(
      photoId: map['photoId'],
      date: DateTime.parse(map['date']),
      confidence: map['confidence'],
      metrics: (map['metrics'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, MetricValue.fromMap(v))),
    );
  }
}

/// Completed challenge record
class CompletedChallenge {
  final String challengeId;
  final DateTime completedAt;
  final String category;

  CompletedChallenge({
    required this.challengeId,
    required this.completedAt,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'challengeId': challengeId,
      'completedAt': completedAt.toIso8601String(),
      'category': category,
    };
  }

  factory CompletedChallenge.fromMap(Map<String, dynamic> map) {
    return CompletedChallenge(
      challengeId: map['challengeId'],
      completedAt: DateTime.parse(map['completedAt']),
      category: map['category'],
    );
  }
}

/// App settings
class AppSettings {
  final bool notifications;
  final bool haptics;

  AppSettings({
    this.notifications = true,
    this.haptics = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications,
      'haptics': haptics,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      notifications: map['notifications'] ?? true,
      haptics: map['haptics'] ?? true,
    );
  }

  AppSettings copyWith({
    bool? notifications,
    bool? haptics,
  }) {
    return AppSettings(
      notifications: notifications ?? this.notifications,
      haptics: haptics ?? this.haptics,
    );
  }
}
