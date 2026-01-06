import 'dart:convert';
import 'photo_model.dart';
import 'mental_health_model.dart';
import 'geometry_metrics_model.dart';

/// Main app state model
class AppStateModel {
  final bool hasCompletedOnboarding;
  final String? baselinePhotoId;
  final DateTime? baselineDate;
  final Map<String, MetricValue> metrics;
  final List<TimelineEntry> timeline;
  final List<CompletedChallenge> challenges;
  final int challengeStreak;
  final DateTime? lastChallengeDate;
  final double? progressScore;
  final DateTime? progressUnlockedAt;
  final AppSettings settings;
  final DateTime createdAt;
  final UsageTracker usageTracker;
  final GeometryAnalysisResult? latestGeometryAnalysis;
  final int? userAge; // For age-appropriate content filtering

  AppStateModel({
    this.hasCompletedOnboarding = false,
    this.baselinePhotoId,
    this.baselineDate,
    this.metrics = const {},
    this.timeline = const [],
    this.challenges = const [],
    this.challengeStreak = 0,
    this.lastChallengeDate,
    this.progressScore,
    this.progressUnlockedAt,
    AppSettings? settings,
    DateTime? createdAt,
    UsageTracker? usageTracker,
    this.latestGeometryAnalysis,
    this.userAge,
  })  : settings = settings ?? AppSettings(),
        createdAt = createdAt ?? DateTime.now(),
        usageTracker = usageTracker ?? UsageTracker();

  /// Create initial state
  factory AppStateModel.initial() {
    return AppStateModel(createdAt: DateTime.now());
  }

  /// Convert to JSON string for storage
  String toJson() {
    return jsonEncode({
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'baselinePhotoId': baselinePhotoId,
      'baselineDate': baselineDate?.toIso8601String(),
      'metrics': metrics.map((k, v) => MapEntry(k, v.toMap())),
      'timeline': timeline.map((e) => e.toMap()).toList(),
      'challenges': challenges.map((e) => e.toMap()).toList(),
      'challengeStreak': challengeStreak,
      'lastChallengeDate': lastChallengeDate?.toIso8601String(),
      'progressScore': progressScore,
      'progressUnlockedAt': progressUnlockedAt?.toIso8601String(),
      'settings': settings.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'usageTracker': usageTracker.toMap(),
      'latestGeometryAnalysis': latestGeometryAnalysis?.toMap(),
      'userAge': userAge,
    });
  }

  /// Create from JSON string
  factory AppStateModel.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return AppStateModel(
      hasCompletedOnboarding: map['hasCompletedOnboarding'] ?? false,
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
      settings: map['settings'] != null
          ? AppSettings.fromMap(map['settings'])
          : AppSettings(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      usageTracker: map['usageTracker'] != null
          ? UsageTracker.fromMap(map['usageTracker'])
          : UsageTracker(),
      latestGeometryAnalysis: map['latestGeometryAnalysis'] != null
          ? GeometryAnalysisResult.fromMap(map['latestGeometryAnalysis'])
          : null,
      userAge: map['userAge'],
    );
  }

  AppStateModel copyWith({
    bool? hasCompletedOnboarding,
    String? baselinePhotoId,
    DateTime? baselineDate,
    Map<String, MetricValue>? metrics,
    List<TimelineEntry>? timeline,
    List<CompletedChallenge>? challenges,
    int? challengeStreak,
    DateTime? lastChallengeDate,
    double? progressScore,
    DateTime? progressUnlockedAt,
    AppSettings? settings,
    DateTime? createdAt,
    UsageTracker? usageTracker,
    GeometryAnalysisResult? latestGeometryAnalysis,
    int? userAge,
  }) {
    return AppStateModel(
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      baselinePhotoId: baselinePhotoId ?? this.baselinePhotoId,
      baselineDate: baselineDate ?? this.baselineDate,
      metrics: metrics ?? this.metrics,
      timeline: timeline ?? this.timeline,
      challenges: challenges ?? this.challenges,
      challengeStreak: challengeStreak ?? this.challengeStreak,
      lastChallengeDate: lastChallengeDate ?? this.lastChallengeDate,
      progressScore: progressScore ?? this.progressScore,
      progressUnlockedAt: progressUnlockedAt ?? this.progressUnlockedAt,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      usageTracker: usageTracker ?? this.usageTracker,
      latestGeometryAnalysis:
          latestGeometryAnalysis ?? this.latestGeometryAnalysis,
      userAge: userAge ?? this.userAge,
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
  final bool showMentalHealthReminders;
  final bool showCulturalDisclaimers;
  final bool showEvidenceLabels;
  final ParentalControls parentalControls;
  final bool wellnessMode; // Reduces analysis frequency reminders
  final bool showScientificCitations;

  AppSettings({
    this.notifications = true,
    this.haptics = true,
    this.showMentalHealthReminders = true,
    this.showCulturalDisclaimers = true,
    this.showEvidenceLabels = true,
    ParentalControls? parentalControls,
    this.wellnessMode = false,
    this.showScientificCitations = true,
  }) : parentalControls = parentalControls ?? ParentalControls();

  Map<String, dynamic> toMap() {
    return {
      'notifications': notifications,
      'haptics': haptics,
      'showMentalHealthReminders': showMentalHealthReminders,
      'showCulturalDisclaimers': showCulturalDisclaimers,
      'showEvidenceLabels': showEvidenceLabels,
      'parentalControls': parentalControls.toMap(),
      'wellnessMode': wellnessMode,
      'showScientificCitations': showScientificCitations,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      notifications: map['notifications'] ?? true,
      haptics: map['haptics'] ?? true,
      showMentalHealthReminders: map['showMentalHealthReminders'] ?? true,
      showCulturalDisclaimers: map['showCulturalDisclaimers'] ?? true,
      showEvidenceLabels: map['showEvidenceLabels'] ?? true,
      parentalControls: map['parentalControls'] != null
          ? ParentalControls.fromMap(map['parentalControls'])
          : ParentalControls(),
      wellnessMode: map['wellnessMode'] ?? false,
      showScientificCitations: map['showScientificCitations'] ?? true,
    );
  }

  AppSettings copyWith({
    bool? notifications,
    bool? haptics,
    bool? showMentalHealthReminders,
    bool? showCulturalDisclaimers,
    bool? showEvidenceLabels,
    ParentalControls? parentalControls,
    bool? wellnessMode,
    bool? showScientificCitations,
  }) {
    return AppSettings(
      notifications: notifications ?? this.notifications,
      haptics: haptics ?? this.haptics,
      showMentalHealthReminders:
          showMentalHealthReminders ?? this.showMentalHealthReminders,
      showCulturalDisclaimers:
          showCulturalDisclaimers ?? this.showCulturalDisclaimers,
      showEvidenceLabels: showEvidenceLabels ?? this.showEvidenceLabels,
      parentalControls: parentalControls ?? this.parentalControls,
      wellnessMode: wellnessMode ?? this.wellnessMode,
      showScientificCitations:
          showScientificCitations ?? this.showScientificCitations,
    );
  }
}
