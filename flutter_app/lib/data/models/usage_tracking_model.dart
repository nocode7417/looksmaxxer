import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';

/// Screen types for usage tracking
enum ScreenType {
  analysis,
  timeline,
  comparison,
  camera,
  dashboard,
  settings,
  other;

  String get displayName {
    switch (this) {
      case ScreenType.analysis:
        return 'Analysis';
      case ScreenType.timeline:
        return 'Timeline';
      case ScreenType.comparison:
        return 'Comparison';
      case ScreenType.camera:
        return 'Camera';
      case ScreenType.dashboard:
        return 'Dashboard';
      case ScreenType.settings:
        return 'Settings';
      case ScreenType.other:
        return 'Other';
    }
  }

  static ScreenType fromString(String value) {
    return ScreenType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ScreenType.other,
    );
  }
}

/// Usage alert types for mental health intervention
enum UsageAlertType {
  frequentUsage,
  consecutiveDays,
  rapidAnalysis,
  lateNight,
  excessiveWeekly;

  String get title {
    switch (this) {
      case UsageAlertType.frequentUsage:
        return 'Taking a Break';
      case UsageAlertType.consecutiveDays:
        return 'Mindful Check-in';
      case UsageAlertType.rapidAnalysis:
        return 'Slow Down';
      case UsageAlertType.lateNight:
        return 'Late Night Usage';
      case UsageAlertType.excessiveWeekly:
        return 'Weekly Reflection';
    }
  }

  String get message {
    switch (this) {
      case UsageAlertType.frequentUsage:
        return 'You\'ve been using the app frequently today. Remember, your worth isn\'t defined by metrics.';
      case UsageAlertType.consecutiveDays:
        return 'You\'ve been checking your metrics daily. It\'s healthy to take breaks from tracking.';
      case UsageAlertType.rapidAnalysis:
        return 'Multiple analyses in a short time detected. Try to focus on long-term progress, not instant changes.';
      case UsageAlertType.lateNight:
        return 'It\'s late - consider getting some rest. Good sleep is more valuable than any metric.';
      case UsageAlertType.excessiveWeekly:
        return 'You\'ve done many analyses this week. Consider focusing on habits over measurements.';
    }
  }

  String get supportText {
    return 'Remember: These measurements don\'t define your worth. Beauty is subjective, and you are valuable exactly as you are.';
  }

  static UsageAlertType fromString(String value) {
    return UsageAlertType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UsageAlertType.frequentUsage,
    );
  }
}

/// User's response to intervention
enum InterventionResponse {
  dismissed,
  resourcesViewed,
  breakTaken;

  String get displayName {
    switch (this) {
      case InterventionResponse.dismissed:
        return 'Dismissed';
      case InterventionResponse.resourcesViewed:
        return 'Viewed Resources';
      case InterventionResponse.breakTaken:
        return 'Took Break';
    }
  }

  static InterventionResponse fromString(String value) {
    return InterventionResponse.values.firstWhere(
      (e) => e.name == value,
      orElse: () => InterventionResponse.dismissed,
    );
  }
}

/// Individual usage session
class UsageSession {
  final String id;
  final DateTime sessionStart;
  final DateTime? sessionEnd;
  final ScreenType screenType;
  final int analysisCount;
  final int interactionCount;
  final DateTime createdAt;

  UsageSession({
    String? id,
    required this.sessionStart,
    this.sessionEnd,
    required this.screenType,
    this.analysisCount = 0,
    this.interactionCount = 0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Create a new session starting now
  factory UsageSession.start(ScreenType screenType) {
    return UsageSession(
      sessionStart: DateTime.now(),
      screenType: screenType,
    );
  }

  /// Session duration
  Duration get duration {
    final end = sessionEnd ?? DateTime.now();
    return end.difference(sessionStart);
  }

  /// Check if session is active
  bool get isActive => sessionEnd == null;

  /// End the session
  UsageSession end() {
    return copyWith(sessionEnd: DateTime.now());
  }

  /// Increment analysis count
  UsageSession incrementAnalysis() {
    return copyWith(analysisCount: analysisCount + 1);
  }

  /// Increment interaction count
  UsageSession incrementInteraction() {
    return copyWith(interactionCount: interactionCount + 1);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionStart': sessionStart.toIso8601String(),
      'sessionEnd': sessionEnd?.toIso8601String(),
      'screenType': screenType.name,
      'analysisCount': analysisCount,
      'interactionCount': interactionCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UsageSession.fromMap(Map<String, dynamic> map) {
    return UsageSession(
      id: map['id'] as String,
      sessionStart: DateTime.parse(map['sessionStart'] as String),
      sessionEnd: map['sessionEnd'] != null
          ? DateTime.parse(map['sessionEnd'] as String)
          : null,
      screenType: ScreenType.fromString(map['screenType'] as String),
      analysisCount: map['analysisCount'] as int,
      interactionCount: map['interactionCount'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  UsageSession copyWith({
    String? id,
    DateTime? sessionStart,
    DateTime? sessionEnd,
    ScreenType? screenType,
    int? analysisCount,
    int? interactionCount,
    DateTime? createdAt,
  }) {
    return UsageSession(
      id: id ?? this.id,
      sessionStart: sessionStart ?? this.sessionStart,
      sessionEnd: sessionEnd ?? this.sessionEnd,
      screenType: screenType ?? this.screenType,
      analysisCount: analysisCount ?? this.analysisCount,
      interactionCount: interactionCount ?? this.interactionCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Aggregated usage pattern data
class UsagePattern {
  final int dailySessionCount;
  final int consecutiveDaysActive;
  final int analysisCountToday;
  final int analysisCountThisWeek;
  final DateTime? lastAnalysisTime;
  final Duration averageSessionDuration;
  final List<DateTime> recentAnalysisTimes;

  UsagePattern({
    required this.dailySessionCount,
    required this.consecutiveDaysActive,
    required this.analysisCountToday,
    required this.analysisCountThisWeek,
    this.lastAnalysisTime,
    required this.averageSessionDuration,
    this.recentAnalysisTimes = const [],
  });

  factory UsagePattern.empty() {
    return UsagePattern(
      dailySessionCount: 0,
      consecutiveDaysActive: 0,
      analysisCountToday: 0,
      analysisCountThisWeek: 0,
      averageSessionDuration: Duration.zero,
    );
  }

  /// Detect if any alert should be triggered
  UsageAlertType? get currentAlert {
    // Check for rapid analysis (3+ in 30 seconds)
    if (recentAnalysisTimes.length >= AppConstants.rapidAnalysisCount) {
      final now = DateTime.now();
      final recentCount = recentAnalysisTimes.where((time) {
        return now.difference(time).inSeconds <
            AppConstants.rapidAnalysisThresholdSeconds;
      }).length;
      if (recentCount >= AppConstants.rapidAnalysisCount) {
        return UsageAlertType.rapidAnalysis;
      }
    }

    // Check for late night usage (10pm - 4am)
    final hour = DateTime.now().hour;
    if (hour >= 22 || hour < 4) {
      if (analysisCountToday > 0) {
        return UsageAlertType.lateNight;
      }
    }

    // Check for frequent daily usage
    if (analysisCountToday >= AppConstants.maxDailyAnalyses) {
      return UsageAlertType.frequentUsage;
    }

    // Check for excessive weekly usage
    if (analysisCountThisWeek >= AppConstants.maxWeeklyAnalyses) {
      return UsageAlertType.excessiveWeekly;
    }

    // Check for consecutive days
    if (consecutiveDaysActive >= AppConstants.consecutiveDaysWarning) {
      return UsageAlertType.consecutiveDays;
    }

    return null;
  }

  /// Check if user is approaching limits
  bool get isApproachingDailyLimit =>
      analysisCountToday >= AppConstants.maxDailyAnalyses - 1;

  /// Remaining analyses today
  int get remainingAnalysesToday =>
      (AppConstants.maxDailyAnalyses - analysisCountToday).clamp(0, AppConstants.maxDailyAnalyses);

  /// Calculate pattern from sessions
  factory UsagePattern.fromSessions(List<UsageSession> sessions) {
    if (sessions.isEmpty) {
      return UsagePattern.empty();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    // Count today's sessions and analyses
    int dailySessionCount = 0;
    int analysisCountToday = 0;
    int analysisCountThisWeek = 0;
    DateTime? lastAnalysisTime;
    final recentAnalysisTimes = <DateTime>[];

    Duration totalDuration = Duration.zero;
    int sessionWithDurationCount = 0;

    // Track unique days for consecutive days calculation
    final uniqueDays = <String>{};

    for (final session in sessions) {
      final sessionDate = DateTime(
        session.sessionStart.year,
        session.sessionStart.month,
        session.sessionStart.day,
      );

      // Track unique days
      uniqueDays.add(
        '${sessionDate.year}-${sessionDate.month}-${sessionDate.day}',
      );

      // Today's data
      if (sessionDate == today) {
        dailySessionCount++;
        analysisCountToday += session.analysisCount;
      }

      // This week's data
      if (session.sessionStart.isAfter(weekAgo)) {
        analysisCountThisWeek += session.analysisCount;
      }

      // Track analysis times
      if (session.analysisCount > 0) {
        lastAnalysisTime ??= session.sessionStart;
        if (session.sessionStart.isAfter(lastAnalysisTime!)) {
          lastAnalysisTime = session.sessionStart;
        }

        // Add to recent times (for rapid analysis detection)
        if (now.difference(session.sessionStart).inMinutes < 5) {
          for (int i = 0; i < session.analysisCount; i++) {
            recentAnalysisTimes.add(session.sessionStart);
          }
        }
      }

      // Calculate average duration
      if (session.sessionEnd != null) {
        totalDuration += session.duration;
        sessionWithDurationCount++;
      }
    }

    // Calculate consecutive days
    int consecutiveDays = 0;
    DateTime checkDate = today;
    while (uniqueDays.contains(
      '${checkDate.year}-${checkDate.month}-${checkDate.day}',
    )) {
      consecutiveDays++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    final avgDuration = sessionWithDurationCount > 0
        ? Duration(
            milliseconds:
                totalDuration.inMilliseconds ~/ sessionWithDurationCount,
          )
        : Duration.zero;

    return UsagePattern(
      dailySessionCount: dailySessionCount,
      consecutiveDaysActive: consecutiveDays,
      analysisCountToday: analysisCountToday,
      analysisCountThisWeek: analysisCountThisWeek,
      lastAnalysisTime: lastAnalysisTime,
      averageSessionDuration: avgDuration,
      recentAnalysisTimes: recentAnalysisTimes,
    );
  }
}

/// Intervention record
class Intervention {
  final String id;
  final DateTime triggeredAt;
  final UsageAlertType triggerType;
  final bool wasAcknowledged;
  final InterventionResponse? userResponse;

  Intervention({
    String? id,
    required this.triggeredAt,
    required this.triggerType,
    this.wasAcknowledged = false,
    this.userResponse,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'triggeredAt': triggeredAt.toIso8601String(),
      'triggerType': triggerType.name,
      'wasAcknowledged': wasAcknowledged ? 1 : 0,
      'userResponse': userResponse?.name,
    };
  }

  factory Intervention.fromMap(Map<String, dynamic> map) {
    return Intervention(
      id: map['id'] as String,
      triggeredAt: DateTime.parse(map['triggeredAt'] as String),
      triggerType: UsageAlertType.fromString(map['triggerType'] as String),
      wasAcknowledged: (map['wasAcknowledged'] as int) == 1,
      userResponse: map['userResponse'] != null
          ? InterventionResponse.fromString(map['userResponse'] as String)
          : null,
    );
  }

  Intervention acknowledge(InterventionResponse response) {
    return Intervention(
      id: id,
      triggeredAt: triggeredAt,
      triggerType: triggerType,
      wasAcknowledged: true,
      userResponse: response,
    );
  }
}

/// Crisis resource information
class CrisisResource {
  final String name;
  final String description;
  final String? phone;
  final String? website;
  final String? textLine;

  const CrisisResource({
    required this.name,
    required this.description,
    this.phone,
    this.website,
    this.textLine,
  });

  static const List<CrisisResource> allResources = [
    CrisisResource(
      name: 'Crisis Text Line',
      description: 'Free, 24/7 support for those in crisis',
      textLine: 'Text HOME to 741741',
    ),
    CrisisResource(
      name: '988 Suicide & Crisis Lifeline',
      description: '24/7 mental health crisis support',
      phone: '988',
      website: '988lifeline.org',
    ),
    CrisisResource(
      name: 'NAMI Helpline',
      description: 'Mental health information and referrals',
      phone: '1-800-950-6264',
      website: 'nami.org',
    ),
    CrisisResource(
      name: 'BDD Foundation',
      description: 'Body Dysmorphic Disorder support',
      website: 'bddfoundation.org',
    ),
    CrisisResource(
      name: 'National Eating Disorders Association',
      description: 'Eating disorder support and resources',
      phone: '1-800-931-2237',
      website: 'nationaleatingdisorders.org',
    ),
  ];
}
