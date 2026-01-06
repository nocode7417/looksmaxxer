/// Mental health safeguards for teen users
/// Implements usage monitoring, intervention messaging, and crisis resources

/// Usage pattern flags for concerning behavior
enum UsageFlag {
  excessiveDaily,      // More than 5 analyses per day
  consecutiveDays,     // Daily usage for 7+ consecutive days
  repeatedPhoto,       // Repeated analysis of same photo
  lateNight,           // Sessions between 10pm-4am
  rapidAnalyses,       // Multiple analyses in quick succession
  excessiveWeekly,     // More than 20 analyses per week
}

extension UsageFlagExtension on UsageFlag {
  String get title {
    switch (this) {
      case UsageFlag.excessiveDaily:
        return 'High Daily Usage';
      case UsageFlag.consecutiveDays:
        return 'Consecutive Day Streak';
      case UsageFlag.repeatedPhoto:
        return 'Repeated Analysis';
      case UsageFlag.lateNight:
        return 'Late Night Session';
      case UsageFlag.rapidAnalyses:
        return 'Rapid Analyses';
      case UsageFlag.excessiveWeekly:
        return 'High Weekly Usage';
    }
  }

  String get description {
    switch (this) {
      case UsageFlag.excessiveDaily:
        return 'You\'ve analyzed your face many times today.';
      case UsageFlag.consecutiveDays:
        return 'You\'ve been using the app daily for a while now.';
      case UsageFlag.repeatedPhoto:
        return 'You\'ve analyzed the same photo multiple times.';
      case UsageFlag.lateNight:
        return 'It\'s late - consider getting some rest.';
      case UsageFlag.rapidAnalyses:
        return 'Multiple analyses in a short time don\'t provide more insight.';
      case UsageFlag.excessiveWeekly:
        return 'You\'ve used the app frequently this week.';
    }
  }

  int get severity {
    switch (this) {
      case UsageFlag.excessiveDaily:
        return 3;
      case UsageFlag.consecutiveDays:
        return 2;
      case UsageFlag.repeatedPhoto:
        return 4;
      case UsageFlag.lateNight:
        return 2;
      case UsageFlag.rapidAnalyses:
        return 3;
      case UsageFlag.excessiveWeekly:
        return 2;
    }
  }
}

/// Usage tracking data
class UsageTracker {
  final List<AnalysisSession> sessions;
  final int consecutiveDays;
  final DateTime? lastAnalysisDate;
  final Map<String, int> photoAnalysisCounts; // photoId -> count
  final List<UsageFlag> activeFlags;
  final DateTime? lastInterventionShown;
  final int interventionDismissCount;

  UsageTracker({
    this.sessions = const [],
    this.consecutiveDays = 0,
    this.lastAnalysisDate,
    this.photoAnalysisCounts = const {},
    this.activeFlags = const [],
    this.lastInterventionShown,
    this.interventionDismissCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessions': sessions.map((s) => s.toMap()).toList(),
      'consecutiveDays': consecutiveDays,
      'lastAnalysisDate': lastAnalysisDate?.toIso8601String(),
      'photoAnalysisCounts': photoAnalysisCounts,
      'activeFlags': activeFlags.map((f) => f.name).toList(),
      'lastInterventionShown': lastInterventionShown?.toIso8601String(),
      'interventionDismissCount': interventionDismissCount,
    };
  }

  factory UsageTracker.fromMap(Map<String, dynamic> map) {
    return UsageTracker(
      sessions: (map['sessions'] as List?)
              ?.map((s) => AnalysisSession.fromMap(s))
              .toList() ??
          [],
      consecutiveDays: map['consecutiveDays'] ?? 0,
      lastAnalysisDate: map['lastAnalysisDate'] != null
          ? DateTime.parse(map['lastAnalysisDate'])
          : null,
      photoAnalysisCounts:
          Map<String, int>.from(map['photoAnalysisCounts'] ?? {}),
      activeFlags: (map['activeFlags'] as List?)
              ?.map((f) => UsageFlag.values.firstWhere((v) => v.name == f))
              .toList() ??
          [],
      lastInterventionShown: map['lastInterventionShown'] != null
          ? DateTime.parse(map['lastInterventionShown'])
          : null,
      interventionDismissCount: map['interventionDismissCount'] ?? 0,
    );
  }

  UsageTracker copyWith({
    List<AnalysisSession>? sessions,
    int? consecutiveDays,
    DateTime? lastAnalysisDate,
    Map<String, int>? photoAnalysisCounts,
    List<UsageFlag>? activeFlags,
    DateTime? lastInterventionShown,
    int? interventionDismissCount,
  }) {
    return UsageTracker(
      sessions: sessions ?? this.sessions,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      lastAnalysisDate: lastAnalysisDate ?? this.lastAnalysisDate,
      photoAnalysisCounts: photoAnalysisCounts ?? this.photoAnalysisCounts,
      activeFlags: activeFlags ?? this.activeFlags,
      lastInterventionShown:
          lastInterventionShown ?? this.lastInterventionShown,
      interventionDismissCount:
          interventionDismissCount ?? this.interventionDismissCount,
    );
  }

  /// Get analyses count for today
  int get todayAnalysesCount {
    final today = DateTime.now();
    return sessions.where((s) {
      return s.timestamp.year == today.year &&
          s.timestamp.month == today.month &&
          s.timestamp.day == today.day;
    }).length;
  }

  /// Get analyses count for this week
  int get weeklyAnalysesCount {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return sessions.where((s) => s.timestamp.isAfter(weekAgo)).length;
  }

  /// Check if it's late night (10pm - 4am)
  bool get isLateNight {
    final hour = DateTime.now().hour;
    return hour >= 22 || hour < 4;
  }

  /// Calculate severity score (0-10)
  int get severityScore {
    int score = 0;
    for (final flag in activeFlags) {
      score += flag.severity;
    }
    return score.clamp(0, 10);
  }

  /// Whether intervention should be shown
  bool get shouldShowIntervention {
    if (severityScore < 3) return false;
    if (lastInterventionShown != null) {
      final hoursSinceLastIntervention =
          DateTime.now().difference(lastInterventionShown!).inHours;
      // Don't show more than once every 4 hours
      if (hoursSinceLastIntervention < 4) return false;
    }
    return true;
  }
}

/// Single analysis session record
class AnalysisSession {
  final String id;
  final DateTime timestamp;
  final String? photoId;
  final Duration duration;

  AnalysisSession({
    required this.id,
    required this.timestamp,
    this.photoId,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'photoId': photoId,
      'duration': duration.inMilliseconds,
    };
  }

  factory AnalysisSession.fromMap(Map<String, dynamic> map) {
    return AnalysisSession(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      photoId: map['photoId'],
      duration: Duration(milliseconds: map['duration']),
    );
  }
}

/// Mental health intervention messages
class MentalHealthIntervention {
  final String id;
  final String title;
  final String message;
  final InterventionSeverity severity;
  final List<String> keyPoints;
  final List<CrisisResource>? crisisResources;

  const MentalHealthIntervention({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.keyPoints,
    this.crisisResources,
  });
}

enum InterventionSeverity {
  gentle,   // Friendly reminder
  moderate, // Clear concern
  serious,  // Urgent with resources
}

/// Crisis resources for mental health support
class CrisisResource {
  final String name;
  final String description;
  final String? phoneNumber;
  final String? textLine;
  final String? website;
  final bool isForTeens;

  const CrisisResource({
    required this.name,
    required this.description,
    this.phoneNumber,
    this.textLine,
    this.website,
    this.isForTeens = false,
  });
}

/// Repository of mental health interventions and resources
class MentalHealthRepository {
  /// Crisis resources available
  static const List<CrisisResource> crisisResources = [
    CrisisResource(
      name: 'Crisis Text Line',
      description: 'Free, 24/7 support for those in crisis',
      textLine: 'Text HOME to 741741',
      website: 'https://www.crisistextline.org',
      isForTeens: true,
    ),
    CrisisResource(
      name: 'Teen Line',
      description: 'Teens helping teens',
      phoneNumber: '1-800-852-8336',
      textLine: 'Text TEEN to 839863',
      website: 'https://teenline.org',
      isForTeens: true,
    ),
    CrisisResource(
      name: 'BDD Foundation',
      description: 'Support for Body Dysmorphic Disorder',
      website: 'https://bddfoundation.org',
      isForTeens: true,
    ),
    CrisisResource(
      name: '988 Suicide & Crisis Lifeline',
      description: '24/7 support for mental health crises',
      phoneNumber: '988',
      textLine: 'Text 988',
      website: 'https://988lifeline.org',
      isForTeens: true,
    ),
    CrisisResource(
      name: 'NAMI Helpline',
      description: 'National Alliance on Mental Illness',
      phoneNumber: '1-800-950-6264',
      textLine: 'Text NAMI to 741741',
      website: 'https://nami.org',
      isForTeens: false,
    ),
  ];

  /// Get teen-appropriate resources
  static List<CrisisResource> getTeenResources() {
    return crisisResources.where((r) => r.isForTeens).toList();
  }

  /// Intervention messages based on usage patterns
  static MentalHealthIntervention getIntervention(UsageTracker tracker) {
    final severity = tracker.severityScore;

    if (severity >= 7) {
      return MentalHealthIntervention(
        id: 'serious_intervention',
        title: 'Hey, we\'re a bit concerned',
        message:
            'We\'ve noticed you\'ve been using this app a lot lately. '
            'Spending too much time analyzing your appearance can seriously '
            'affect your mental health and may be a sign of body dysmorphic '
            'disorder (BDD).\n\n'
            'Your worth isn\'t determined by facial measurements or symmetry. '
            'If you\'re feeling anxious about how you look, please talk to '
            'someone you trust.',
        severity: InterventionSeverity.serious,
        keyPoints: [
          'These are just measurements, not your worth',
          'Everyone\'s face is asymmetric to some degree',
          'Social media filters aren\'t reality',
          'You\'re more than your facial proportions',
          'Consider taking a break from appearance-focused apps',
        ],
        crisisResources: getTeenResources(),
      );
    } else if (severity >= 4) {
      return MentalHealthIntervention(
        id: 'moderate_intervention',
        title: 'Quick check-in',
        message:
            'You\'ve been using this app quite a bit. Remember that no app '
            'can fully capture who you are or your value as a person.\n\n'
            'Facial analysis is just one small perspective - it doesn\'t '
            'account for your personality, talents, or the things that actually '
            'matter in life.',
        severity: InterventionSeverity.moderate,
        keyPoints: [
          'Taking a break can improve how you feel',
          'Confidence comes from within, not measurements',
          'Focus on things you can control, like health and kindness',
          'Talk to friends or family about how you\'re feeling',
        ],
        crisisResources: null,
      );
    } else {
      return MentalHealthIntervention(
        id: 'gentle_reminder',
        title: 'Friendly reminder',
        message:
            'Remember: this app is for tracking progress over time, not for '
            'obsessing over small details. The most impactful improvements come '
            'from consistent habits like sleep, hydration, and posture - not '
            'from frequent analysis.',
        severity: InterventionSeverity.gentle,
        keyPoints: [
          'Quality over quantity - one good photo per day is enough',
          'Real changes take weeks to months, not hours',
          'Focus on habits, not measurements',
        ],
        crisisResources: null,
      );
    }
  }

  /// Get late night specific message
  static MentalHealthIntervention getLateNightIntervention() {
    return const MentalHealthIntervention(
      id: 'late_night',
      title: 'It\'s late',
      message:
          'Sleep is one of the most important factors for how you look and feel. '
          'Late night phone use can affect your sleep quality.\n\n'
          'Consider putting your phone away and getting some rest. The app will '
          'still be here tomorrow.',
      severity: InterventionSeverity.gentle,
      keyPoints: [
        'Sleep deprivation affects skin and facial appearance',
        'Blue light can disrupt your sleep cycle',
        'Rest is more valuable than analysis right now',
      ],
      crisisResources: null,
    );
  }

  /// Disclaimers that should be shown
  static const String generalDisclaimer =
      'This app provides educational information only and is not medical advice. '
      'The exercises shown are not medical treatment. See a healthcare provider '
      'for any medical concerns.';

  static const String teenDisclaimer =
      'Talk to a parent or guardian about any concerns you have. If you\'re '
      'feeling anxious about your appearance, please reach out to a trusted '
      'adult or counselor.';

  static const String exerciseDisclaimer =
      'These exercises are not medical treatment. Stop immediately if you '
      'experience pain. See a doctor or dentist if you have jaw pain, TMJ '
      'issues, or other concerns.';
}

/// Parental controls settings
class ParentalControls {
  final bool isEnabled;
  final int? dailyUsageLimit; // minutes
  final int? maxAnalysesPerDay;
  final bool notifyOnExcessiveUsage;
  final String? parentEmail;
  final DateTime? lastParentNotification;

  ParentalControls({
    this.isEnabled = false,
    this.dailyUsageLimit,
    this.maxAnalysesPerDay,
    this.notifyOnExcessiveUsage = false,
    this.parentEmail,
    this.lastParentNotification,
  });

  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'dailyUsageLimit': dailyUsageLimit,
      'maxAnalysesPerDay': maxAnalysesPerDay,
      'notifyOnExcessiveUsage': notifyOnExcessiveUsage,
      'parentEmail': parentEmail,
      'lastParentNotification': lastParentNotification?.toIso8601String(),
    };
  }

  factory ParentalControls.fromMap(Map<String, dynamic> map) {
    return ParentalControls(
      isEnabled: map['isEnabled'] ?? false,
      dailyUsageLimit: map['dailyUsageLimit'],
      maxAnalysesPerDay: map['maxAnalysesPerDay'],
      notifyOnExcessiveUsage: map['notifyOnExcessiveUsage'] ?? false,
      parentEmail: map['parentEmail'],
      lastParentNotification: map['lastParentNotification'] != null
          ? DateTime.parse(map['lastParentNotification'])
          : null,
    );
  }

  ParentalControls copyWith({
    bool? isEnabled,
    int? dailyUsageLimit,
    int? maxAnalysesPerDay,
    bool? notifyOnExcessiveUsage,
    String? parentEmail,
    DateTime? lastParentNotification,
  }) {
    return ParentalControls(
      isEnabled: isEnabled ?? this.isEnabled,
      dailyUsageLimit: dailyUsageLimit ?? this.dailyUsageLimit,
      maxAnalysesPerDay: maxAnalysesPerDay ?? this.maxAnalysesPerDay,
      notifyOnExcessiveUsage:
          notifyOnExcessiveUsage ?? this.notifyOnExcessiveUsage,
      parentEmail: parentEmail ?? this.parentEmail,
      lastParentNotification:
          lastParentNotification ?? this.lastParentNotification,
    );
  }
}

/// Usage monitoring service
class UsageMonitor {
  /// Check usage patterns and return active flags
  static List<UsageFlag> checkUsagePatterns(UsageTracker tracker) {
    final flags = <UsageFlag>[];

    // Check excessive daily usage (>5 analyses)
    if (tracker.todayAnalysesCount > 5) {
      flags.add(UsageFlag.excessiveDaily);
    }

    // Check consecutive days (7+)
    if (tracker.consecutiveDays >= 7) {
      flags.add(UsageFlag.consecutiveDays);
    }

    // Check repeated photo analysis
    for (final count in tracker.photoAnalysisCounts.values) {
      if (count >= 3) {
        flags.add(UsageFlag.repeatedPhoto);
        break;
      }
    }

    // Check late night usage
    if (tracker.isLateNight) {
      flags.add(UsageFlag.lateNight);
    }

    // Check rapid analyses (3+ in last 10 minutes)
    final tenMinutesAgo = DateTime.now().subtract(const Duration(minutes: 10));
    final recentSessions =
        tracker.sessions.where((s) => s.timestamp.isAfter(tenMinutesAgo));
    if (recentSessions.length >= 3) {
      flags.add(UsageFlag.rapidAnalyses);
    }

    // Check excessive weekly usage (>20)
    if (tracker.weeklyAnalysesCount > 20) {
      flags.add(UsageFlag.excessiveWeekly);
    }

    return flags;
  }

  /// Record a new analysis session
  static UsageTracker recordSession(
    UsageTracker tracker, {
    required String sessionId,
    String? photoId,
    required Duration duration,
  }) {
    final now = DateTime.now();
    final session = AnalysisSession(
      id: sessionId,
      timestamp: now,
      photoId: photoId,
      duration: duration,
    );

    // Update consecutive days
    int newConsecutiveDays = tracker.consecutiveDays;
    if (tracker.lastAnalysisDate != null) {
      final daysSinceLastAnalysis =
          now.difference(tracker.lastAnalysisDate!).inDays;
      if (daysSinceLastAnalysis == 1) {
        newConsecutiveDays++;
      } else if (daysSinceLastAnalysis > 1) {
        newConsecutiveDays = 1;
      }
    } else {
      newConsecutiveDays = 1;
    }

    // Update photo analysis counts
    final newPhotoAnalysisCounts =
        Map<String, int>.from(tracker.photoAnalysisCounts);
    if (photoId != null) {
      newPhotoAnalysisCounts[photoId] =
          (newPhotoAnalysisCounts[photoId] ?? 0) + 1;
    }

    // Only keep last 100 sessions
    var newSessions = [...tracker.sessions, session];
    if (newSessions.length > 100) {
      newSessions = newSessions.sublist(newSessions.length - 100);
    }

    var updatedTracker = tracker.copyWith(
      sessions: newSessions,
      consecutiveDays: newConsecutiveDays,
      lastAnalysisDate: now,
      photoAnalysisCounts: newPhotoAnalysisCounts,
    );

    // Check and update flags
    final newFlags = checkUsagePatterns(updatedTracker);
    updatedTracker = updatedTracker.copyWith(activeFlags: newFlags);

    return updatedTracker;
  }
}
