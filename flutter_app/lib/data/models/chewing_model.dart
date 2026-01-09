import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';

/// Chewing difficulty level
enum ChewingLevel {
  beginner,
  intermediate,
  advanced;

  int get dailyTargetMinutes {
    switch (this) {
      case ChewingLevel.beginner:
        return AppConstants.chewingBeginnerMinutes;
      case ChewingLevel.intermediate:
        return AppConstants.chewingIntermediateMinutes;
      case ChewingLevel.advanced:
        return AppConstants.chewingAdvancedMinutes;
    }
  }

  String get displayName {
    switch (this) {
      case ChewingLevel.beginner:
        return 'Beginner';
      case ChewingLevel.intermediate:
        return 'Intermediate';
      case ChewingLevel.advanced:
        return 'Advanced';
    }
  }

  String get description {
    switch (this) {
      case ChewingLevel.beginner:
        return '${dailyTargetMinutes} minutes per day';
      case ChewingLevel.intermediate:
        return '${dailyTargetMinutes} minutes per day';
      case ChewingLevel.advanced:
        return '${dailyTargetMinutes} minutes per day';
    }
  }

  static ChewingLevel fromString(String value) {
    return ChewingLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ChewingLevel.beginner,
    );
  }
}

/// Individual chewing session
class ChewingSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationMinutes;
  final bool completed;
  final int targetMinutes;
  final DateTime createdAt;

  ChewingSession({
    String? id,
    required this.startTime,
    this.endTime,
    required this.durationMinutes,
    this.completed = false,
    required this.targetMinutes,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Create a new active session
  factory ChewingSession.start({
    required int targetMinutes,
  }) {
    return ChewingSession(
      startTime: DateTime.now(),
      durationMinutes: targetMinutes,
      targetMinutes: targetMinutes,
      completed: false,
    );
  }

  /// Check if session is currently active
  bool get isActive => endTime == null && !completed;

  /// Remaining seconds in the session
  int get remainingSeconds {
    if (!isActive) return 0;
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    final totalSeconds = durationMinutes * 60;
    return (totalSeconds - elapsed).clamp(0, totalSeconds);
  }

  /// Elapsed seconds in the session
  int get elapsedSeconds {
    if (endTime != null) {
      return endTime!.difference(startTime).inSeconds;
    }
    return DateTime.now().difference(startTime).inSeconds;
  }

  /// Progress percentage (0.0 to 1.0)
  double get progress {
    final totalSeconds = durationMinutes * 60;
    if (totalSeconds == 0) return 0.0;
    return (elapsedSeconds / totalSeconds).clamp(0.0, 1.0);
  }

  /// Complete the session
  ChewingSession complete() {
    return copyWith(
      endTime: DateTime.now(),
      completed: true,
    );
  }

  /// Cancel the session
  ChewingSession cancel() {
    return copyWith(
      endTime: DateTime.now(),
      completed: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'completed': completed ? 1 : 0,
      'targetMinutes': targetMinutes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChewingSession.fromMap(Map<String, dynamic> map) {
    return ChewingSession(
      id: map['id'] as String,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null
          ? DateTime.parse(map['endTime'] as String)
          : null,
      durationMinutes: map['durationMinutes'] as int,
      completed: (map['completed'] as int) == 1,
      targetMinutes: map['targetMinutes'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  ChewingSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    bool? completed,
    int? targetMinutes,
    DateTime? createdAt,
  }) {
    return ChewingSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      completed: completed ?? this.completed,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Aggregated daily chewing statistics
class ChewingDayStats {
  final DateTime date;
  final int totalMinutes;
  final int targetMinutes;
  final int sessionCount;
  final int completedSessions;
  final List<ChewingSession> sessions;

  ChewingDayStats({
    required this.date,
    required this.totalMinutes,
    required this.targetMinutes,
    required this.sessionCount,
    required this.completedSessions,
    required this.sessions,
  });

  /// Whether daily goal was met
  bool get dailyGoalMet => totalMinutes >= targetMinutes;

  /// Progress percentage (0.0 to 1.0)
  double get progress => (totalMinutes / targetMinutes).clamp(0.0, 1.0);

  /// Display progress percentage (can exceed 100%)
  double get displayProgress => totalMinutes / targetMinutes;

  /// Remaining minutes to reach goal
  int get remainingMinutes => (targetMinutes - totalMinutes).clamp(0, targetMinutes);

  /// TMJ safety warning (>60 minutes in a day)
  bool get tmjWarning => totalMinutes > AppConstants.chewingTmjWarningMinutes;

  /// Create from sessions for a specific date
  factory ChewingDayStats.fromSessions({
    required DateTime date,
    required List<ChewingSession> sessions,
    required int targetMinutes,
  }) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final daySessions = sessions.where((s) {
      final sessionDate = DateTime(
        s.startTime.year,
        s.startTime.month,
        s.startTime.day,
      );
      return sessionDate == normalizedDate;
    }).toList();

    final completedSessions = daySessions.where((s) => s.completed).toList();

    // Calculate total minutes from completed sessions
    int totalMinutes = 0;
    for (final session in completedSessions) {
      if (session.endTime != null) {
        final duration = session.endTime!.difference(session.startTime);
        totalMinutes += duration.inMinutes;
      } else {
        totalMinutes += session.durationMinutes;
      }
    }

    return ChewingDayStats(
      date: normalizedDate,
      totalMinutes: totalMinutes,
      targetMinutes: targetMinutes,
      sessionCount: daySessions.length,
      completedSessions: completedSessions.length,
      sessions: daySessions,
    );
  }

  factory ChewingDayStats.empty({
    required DateTime date,
    required int targetMinutes,
  }) {
    return ChewingDayStats(
      date: DateTime(date.year, date.month, date.day),
      totalMinutes: 0,
      targetMinutes: targetMinutes,
      sessionCount: 0,
      completedSessions: 0,
      sessions: [],
    );
  }
}

/// Weekly chewing statistics
class ChewingWeekStats {
  final DateTime weekStart;
  final int totalMinutes;
  final int averageMinutesPerDay;
  final int sessionCount;
  final int daysActive;
  final int daysGoalMet;
  final List<ChewingDayStats> dailyStats;

  ChewingWeekStats({
    required this.weekStart,
    required this.totalMinutes,
    required this.averageMinutesPerDay,
    required this.sessionCount,
    required this.daysActive,
    required this.daysGoalMet,
    required this.dailyStats,
  });

  /// Create from daily stats
  factory ChewingWeekStats.fromDailyStats(List<ChewingDayStats> dailyStats) {
    if (dailyStats.isEmpty) {
      final today = DateTime.now();
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      return ChewingWeekStats(
        weekStart: DateTime(weekStart.year, weekStart.month, weekStart.day),
        totalMinutes: 0,
        averageMinutesPerDay: 0,
        sessionCount: 0,
        daysActive: 0,
        daysGoalMet: 0,
        dailyStats: [],
      );
    }

    final sorted = List<ChewingDayStats>.from(dailyStats)
      ..sort((a, b) => a.date.compareTo(b.date));

    final totalMinutes =
        sorted.fold<int>(0, (sum, day) => sum + day.totalMinutes);
    final sessionCount =
        sorted.fold<int>(0, (sum, day) => sum + day.sessionCount);
    final daysActive = sorted.where((day) => day.totalMinutes > 0).length;
    final daysGoalMet = sorted.where((day) => day.dailyGoalMet).length;
    final averageMinutesPerDay =
        daysActive > 0 ? (totalMinutes / daysActive).round() : 0;

    return ChewingWeekStats(
      weekStart: sorted.first.date,
      totalMinutes: totalMinutes,
      averageMinutesPerDay: averageMinutesPerDay,
      sessionCount: sessionCount,
      daysActive: daysActive,
      daysGoalMet: daysGoalMet,
      dailyStats: sorted,
    );
  }
}

/// Chewing streak information
class ChewingStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCompletedDate;

  ChewingStreak({
    required this.currentStreak,
    required this.longestStreak,
    this.lastCompletedDate,
  });

  factory ChewingStreak.empty() {
    return ChewingStreak(
      currentStreak: 0,
      longestStreak: 0,
    );
  }

  /// Calculate streak from daily stats
  factory ChewingStreak.fromDailyStats(List<ChewingDayStats> dailyStats) {
    if (dailyStats.isEmpty) {
      return ChewingStreak.empty();
    }

    // Sort by date descending
    final sorted = List<ChewingDayStats>.from(dailyStats)
      ..sort((a, b) => b.date.compareTo(a.date));

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastCompletedDate;

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    for (int i = 0; i < sorted.length; i++) {
      final day = sorted[i];

      if (day.dailyGoalMet) {
        tempStreak++;
        lastCompletedDate ??= day.date;

        // Check if this is consecutive for current streak
        if (i == 0) {
          // Most recent day
          final dayDiff = todayNormalized.difference(day.date).inDays;
          if (dayDiff <= 1) {
            currentStreak = tempStreak;
          }
        } else {
          final prevDay = sorted[i - 1];
          final dayDiff = prevDay.date.difference(day.date).inDays;
          if (dayDiff == 1 && currentStreak > 0) {
            currentStreak = tempStreak;
          }
        }
      } else {
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 0;
        if (i == 0) {
          currentStreak = 0;
        }
      }
    }

    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    return ChewingStreak(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastCompletedDate: lastCompletedDate,
    );
  }
}
