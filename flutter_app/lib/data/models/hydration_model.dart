import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';

/// Types of drinks that can be logged
enum DrinkType {
  water,
  tea,
  coffee,
  juice,
  other;

  String get displayName {
    switch (this) {
      case DrinkType.water:
        return 'Water';
      case DrinkType.tea:
        return 'Tea';
      case DrinkType.coffee:
        return 'Coffee';
      case DrinkType.juice:
        return 'Juice';
      case DrinkType.other:
        return 'Other';
    }
  }

  static DrinkType fromString(String value) {
    return DrinkType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => DrinkType.water,
    );
  }
}

/// Activity level for hydration goal calculation
enum ActivityLevel {
  sedentary,
  moderate,
  active;

  String get displayName {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.moderate:
        return 'Moderate';
      case ActivityLevel.active:
        return 'Active';
    }
  }

  String get description {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Mostly sitting, desk work';
      case ActivityLevel.moderate:
        return 'Light exercise, walking';
      case ActivityLevel.active:
        return 'Regular exercise, active job';
    }
  }

  double get mlPerKg {
    switch (this) {
      case ActivityLevel.sedentary:
        return AppConstants.hydrationMlPerKgSedentary;
      case ActivityLevel.moderate:
        return AppConstants.hydrationMlPerKgModerate;
      case ActivityLevel.active:
        return AppConstants.hydrationMlPerKgActive;
    }
  }

  static ActivityLevel fromString(String value) {
    return ActivityLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ActivityLevel.moderate,
    );
  }
}

/// Method used to calculate hydration goal
enum HydrationCalculationMethod {
  defaultAmount,
  personalized;

  static HydrationCalculationMethod fromString(String value) {
    return HydrationCalculationMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HydrationCalculationMethod.defaultAmount,
    );
  }
}

/// Individual hydration log entry
class HydrationLog {
  final String id;
  final DateTime timestamp;
  final int amountMl;
  final DrinkType drinkType;
  final DateTime createdAt;

  HydrationLog({
    String? id,
    required this.timestamp,
    required this.amountMl,
    this.drinkType = DrinkType.water,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'amountMl': amountMl,
      'drinkType': drinkType.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HydrationLog.fromMap(Map<String, dynamic> map) {
    return HydrationLog(
      id: map['id'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      amountMl: map['amountMl'] as int,
      drinkType: DrinkType.fromString(map['drinkType'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  HydrationLog copyWith({
    String? id,
    DateTime? timestamp,
    int? amountMl,
    DrinkType? drinkType,
    DateTime? createdAt,
  }) {
    return HydrationLog(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      amountMl: amountMl ?? this.amountMl,
      drinkType: drinkType ?? this.drinkType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// User's hydration goal configuration
class HydrationGoal {
  final String id;
  final int goalMl;
  final HydrationCalculationMethod calculationMethod;
  final double? weightKg;
  final ActivityLevel? activityLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  HydrationGoal({
    String? id,
    required this.goalMl,
    required this.calculationMethod,
    this.weightKg,
    this.activityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create default goal (2500ml)
  factory HydrationGoal.defaultGoal() {
    return HydrationGoal(
      goalMl: AppConstants.defaultHydrationGoalMl,
      calculationMethod: HydrationCalculationMethod.defaultAmount,
    );
  }

  /// Create personalized goal based on weight and activity level
  factory HydrationGoal.personalized({
    required double weightKg,
    required ActivityLevel activityLevel,
  }) {
    final goalMl = (weightKg * activityLevel.mlPerKg).round();
    return HydrationGoal(
      goalMl: goalMl,
      calculationMethod: HydrationCalculationMethod.personalized,
      weightKg: weightKg,
      activityLevel: activityLevel,
    );
  }

  /// Recalculate goal with new weight (keeps same activity level)
  HydrationGoal recalculateWithWeight(double newWeightKg) {
    if (calculationMethod != HydrationCalculationMethod.personalized ||
        activityLevel == null) {
      return this;
    }
    final newGoalMl = (newWeightKg * activityLevel!.mlPerKg).round();
    return copyWith(
      goalMl: newGoalMl,
      weightKg: newWeightKg,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goalMl': goalMl,
      'calculationMethod': calculationMethod.name,
      'weightKg': weightKg,
      'activityLevel': activityLevel?.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HydrationGoal.fromMap(Map<String, dynamic> map) {
    return HydrationGoal(
      id: map['id'] as String,
      goalMl: map['goalMl'] as int,
      calculationMethod: HydrationCalculationMethod.fromString(
        map['calculationMethod'] as String,
      ),
      weightKg: map['weightKg'] as double?,
      activityLevel: map['activityLevel'] != null
          ? ActivityLevel.fromString(map['activityLevel'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  HydrationGoal copyWith({
    String? id,
    int? goalMl,
    HydrationCalculationMethod? calculationMethod,
    double? weightKg,
    ActivityLevel? activityLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HydrationGoal(
      id: id ?? this.id,
      goalMl: goalMl ?? this.goalMl,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Aggregated daily hydration data
class HydrationDay {
  final DateTime date;
  final int totalMl;
  final int goalMl;
  final List<HydrationLog> logs;

  HydrationDay({
    required this.date,
    required this.totalMl,
    required this.goalMl,
    required this.logs,
  });

  /// Progress percentage (0.0 to 1.0, capped at 1.0)
  double get progressPercentage => (totalMl / goalMl).clamp(0.0, 1.0);

  /// Whether daily goal was reached
  bool get goalReached => totalMl >= goalMl;

  /// Progress percentage for display (can exceed 100%)
  double get displayPercentage => totalMl / goalMl;

  /// Remaining ml to reach goal
  int get remainingMl => (goalMl - totalMl).clamp(0, goalMl);

  /// Create from logs for a specific date
  factory HydrationDay.fromLogs({
    required DateTime date,
    required List<HydrationLog> logs,
    required int goalMl,
  }) {
    final dayLogs = logs.where((log) => _isSameDay(log.timestamp, date)).toList();
    final totalMl = dayLogs.fold<int>(0, (sum, log) => sum + log.amountMl);

    return HydrationDay(
      date: DateTime(date.year, date.month, date.day),
      totalMl: totalMl,
      goalMl: goalMl,
      logs: dayLogs,
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Hydration streak information
class HydrationStreak {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastGoalReachedDate;

  HydrationStreak({
    required this.currentStreak,
    required this.longestStreak,
    this.lastGoalReachedDate,
  });

  factory HydrationStreak.empty() {
    return HydrationStreak(
      currentStreak: 0,
      longestStreak: 0,
    );
  }

  /// Calculate streak from daily history
  factory HydrationStreak.fromHistory(List<HydrationDay> history) {
    if (history.isEmpty) {
      return HydrationStreak.empty();
    }

    // Sort by date descending
    final sorted = List<HydrationDay>.from(history)
      ..sort((a, b) => b.date.compareTo(a.date));

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastGoalDate;

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    for (int i = 0; i < sorted.length; i++) {
      final day = sorted[i];

      if (day.goalReached) {
        tempStreak++;
        lastGoalDate ??= day.date;

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

    return HydrationStreak(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastGoalReachedDate: lastGoalDate,
    );
  }
}
