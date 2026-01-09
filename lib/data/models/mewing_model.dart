import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';

/// Mewing session for daily check-in tracking
class MewingSession {
  final String id;
  final DateTime date; // Normalized to midnight
  final bool checkedIn;
  final int? durationMinutes;
  final String? notes;
  final DateTime createdAt;

  MewingSession({
    String? id,
    required this.date,
    this.checkedIn = false,
    this.durationMinutes,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Create a new session for today
  factory MewingSession.today() {
    final now = DateTime.now();
    return MewingSession(
      date: DateTime(now.year, now.month, now.day),
      checkedIn: false,
    );
  }

  /// Create a checked-in session for today
  factory MewingSession.checkInToday({int? durationMinutes, String? notes}) {
    final now = DateTime.now();
    return MewingSession(
      date: DateTime(now.year, now.month, now.day),
      checkedIn: true,
      durationMinutes: durationMinutes,
      notes: notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': _dateToString(date),
      'checkedIn': checkedIn ? 1 : 0,
      'durationMinutes': durationMinutes,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MewingSession.fromMap(Map<String, dynamic> map) {
    return MewingSession(
      id: map['id'] as String,
      date: _dateFromString(map['date'] as String),
      checkedIn: (map['checkedIn'] as int) == 1,
      durationMinutes: map['durationMinutes'] as int?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  MewingSession copyWith({
    String? id,
    DateTime? date,
    bool? checkedIn,
    int? durationMinutes,
    String? notes,
    DateTime? createdAt,
  }) {
    return MewingSession(
      id: id ?? this.id,
      date: date ?? this.date,
      checkedIn: checkedIn ?? this.checkedIn,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert date to string (YYYY-MM-DD format)
  static String _dateToString(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Parse date from string (YYYY-MM-DD format)
  static DateTime _dateFromString(String dateStr) {
    final parts = dateStr.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}

/// Mewing milestone achievement
class StreakMilestone {
  final int days;
  final String title;
  final String description;
  final bool achieved;
  final DateTime? achievedAt;

  const StreakMilestone({
    required this.days,
    required this.title,
    required this.description,
    this.achieved = false,
    this.achievedAt,
  });

  /// All available milestones
  static const List<StreakMilestone> allMilestones = [
    StreakMilestone(
      days: 7,
      title: 'Week Warrior',
      description: 'First week complete!',
    ),
    StreakMilestone(
      days: 30,
      title: 'Month Master',
      description: '30 days of consistency',
    ),
    StreakMilestone(
      days: 90,
      title: 'Quarter Champion',
      description: '90 days strong',
    ),
    StreakMilestone(
      days: 180,
      title: 'Half-Year Hero',
      description: '6 months dedicated',
    ),
    StreakMilestone(
      days: 365,
      title: 'Year Legend',
      description: 'Full year achievement',
    ),
  ];

  /// Get milestone for specific days
  static StreakMilestone? getMilestoneForDays(int days) {
    try {
      return allMilestones.firstWhere((m) => m.days == days);
    } catch (_) {
      return null;
    }
  }

  /// Get next milestone after current streak
  static StreakMilestone? getNextMilestone(int currentStreak) {
    try {
      return allMilestones.firstWhere((m) => m.days > currentStreak);
    } catch (_) {
      return null;
    }
  }

  StreakMilestone copyWith({
    int? days,
    String? title,
    String? description,
    bool? achieved,
    DateTime? achievedAt,
  }) {
    return StreakMilestone(
      days: days ?? this.days,
      title: title ?? this.title,
      description: description ?? this.description,
      achieved: achieved ?? this.achieved,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }
}

/// Mewing streak tracking
class MewingStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastCheckInDate;
  final List<StreakMilestone> achievedMilestones;
  final int totalCheckIns;

  const MewingStreak({
    required this.currentStreak,
    required this.longestStreak,
    this.lastCheckInDate,
    this.achievedMilestones = const [],
    this.totalCheckIns = 0,
  });

  factory MewingStreak.empty() {
    return MewingStreak(
      currentStreak: 0,
      longestStreak: 0,
    );
  }

  /// Check if user has checked in today
  bool get isActiveToday {
    if (lastCheckInDate == null) return false;
    final now = DateTime.now();
    return lastCheckInDate!.year == now.year &&
        lastCheckInDate!.month == now.month &&
        lastCheckInDate!.day == now.day;
  }

  /// Get next milestone to achieve
  StreakMilestone? get nextMilestone {
    return StreakMilestone.getNextMilestone(currentStreak);
  }

  /// Progress to next milestone (0.0 to 1.0)
  double get progressToNextMilestone {
    final next = nextMilestone;
    if (next == null) return 1.0;

    // Find previous milestone
    final previousMilestone = StreakMilestone.allMilestones
        .where((m) => m.days <= currentStreak)
        .lastOrNull;
    final startDays = previousMilestone?.days ?? 0;

    final range = next.days - startDays;
    final progress = currentStreak - startDays;
    return (progress / range).clamp(0.0, 1.0);
  }

  /// Days until next milestone
  int get daysUntilNextMilestone {
    final next = nextMilestone;
    if (next == null) return 0;
    return next.days - currentStreak;
  }

  /// Calculate streak from sessions history
  factory MewingStreak.fromSessions(List<MewingSession> sessions) {
    if (sessions.isEmpty) {
      return MewingStreak.empty();
    }

    // Filter to only checked-in sessions and sort by date descending
    final checkedIn = sessions.where((s) => s.checkedIn).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (checkedIn.isEmpty) {
      return MewingStreak.empty();
    }

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastCheckIn = checkedIn.first.date;

    // Calculate current streak
    DateTime expectedDate = todayNormalized;

    for (final session in checkedIn) {
      final sessionDate = session.date;
      final dayDiff = expectedDate.difference(sessionDate).inDays;

      if (dayDiff == 0) {
        // This is the expected date
        tempStreak++;
        expectedDate = sessionDate.subtract(const Duration(days: 1));
      } else if (dayDiff == 1) {
        // Yesterday's date, continue streak
        tempStreak++;
        expectedDate = sessionDate.subtract(const Duration(days: 1));
      } else {
        // Gap in streak
        break;
      }
    }
    currentStreak = tempStreak;

    // Calculate longest streak
    tempStreak = 0;
    DateTime? prevDate;

    for (final session in checkedIn.reversed) {
      if (prevDate == null) {
        tempStreak = 1;
      } else {
        final dayDiff = session.date.difference(prevDate).inDays;
        if (dayDiff == 1) {
          tempStreak++;
        } else if (dayDiff > 1) {
          longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
          tempStreak = 1;
        }
      }
      prevDate = session.date;
    }
    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    // Determine achieved milestones
    final achieved = <StreakMilestone>[];
    for (final milestone in StreakMilestone.allMilestones) {
      if (longestStreak >= milestone.days) {
        achieved.add(milestone.copyWith(achieved: true));
      }
    }

    return MewingStreak(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastCheckInDate: lastCheckIn,
      achievedMilestones: achieved,
    );
  }

  MewingStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastCheckInDate,
    List<StreakMilestone>? achievedMilestones,
  }) {
    return MewingStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      achievedMilestones: achievedMilestones ?? this.achievedMilestones,
    );
  }
}

/// Monthly mewing data for calendar display
class MewingMonth {
  final int year;
  final int month;
  final Map<int, bool> dailyStatus; // day -> checkedIn
  final List<MewingSession> sessions;

  MewingMonth({
    required this.year,
    required this.month,
    required this.dailyStatus,
    this.sessions = const [],
  });

  /// Create from sessions for a specific month
  factory MewingMonth.fromSessions({
    required int year,
    required int month,
    required List<MewingSession> sessions,
  }) {
    final dailyStatus = <int, bool>{};
    final monthSessions = <MewingSession>[];

    for (final session in sessions) {
      if (session.date.year == year && session.date.month == month) {
        dailyStatus[session.date.day] = session.checkedIn;
        monthSessions.add(session);
      }
    }

    return MewingMonth(
      year: year,
      month: month,
      dailyStatus: dailyStatus,
      sessions: monthSessions,
    );
  }

  /// Get check-in status for a specific day
  bool? getStatus(int day) => dailyStatus[day];

  /// Total checked-in days this month
  int get checkedInDays =>
      dailyStatus.values.where((v) => v).length;

  /// Total days with any session
  int get totalDays => dailyStatus.length;
}
