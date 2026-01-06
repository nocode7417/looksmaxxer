import '../core/constants/app_constants.dart';

/// Anti-cheat system for photo uploads
/// Matches the original React app's antiCheat.js functionality
class AntiCheat {
  static final List<DateTime> _recentUploads = [];

  /// Check if upload is allowed (rate limiting)
  static RateLimitResult checkRateLimit() {
    final now = DateTime.now();

    // Clean old entries
    _recentUploads.removeWhere(
      (time) => now.difference(time).inHours > 24,
    );

    // Check hourly limit
    final hourAgo = now.subtract(const Duration(hours: 1));
    final uploadsLastHour =
        _recentUploads.where((t) => t.isAfter(hourAgo)).length;

    if (uploadsLastHour >= AppConstants.maxUploadsPerHour) {
      final oldestInHour = _recentUploads
          .where((t) => t.isAfter(hourAgo))
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final waitMinutes =
          60 - now.difference(oldestInHour).inMinutes;

      return RateLimitResult(
        allowed: false,
        reason: 'Hourly limit reached',
        waitMinutes: waitMinutes,
      );
    }

    // Check daily limit
    final dayStart = DateTime(now.year, now.month, now.day);
    final uploadsToday =
        _recentUploads.where((t) => t.isAfter(dayStart)).length;

    if (uploadsToday >= AppConstants.maxUploadsPerDay) {
      final minutesUntilMidnight =
          DateTime(now.year, now.month, now.day + 1).difference(now).inMinutes;

      return RateLimitResult(
        allowed: false,
        reason: 'Daily limit reached',
        waitMinutes: minutesUntilMidnight,
      );
    }

    return RateLimitResult(allowed: true);
  }

  /// Record an upload
  static void recordUpload() {
    _recentUploads.add(DateTime.now());
  }

  /// Check for suspicious patterns
  static SuspiciousActivityResult checkSuspiciousActivity(
    List<DateTime> uploadHistory,
  ) {
    if (uploadHistory.length < 3) {
      return SuspiciousActivityResult(isSuspicious: false);
    }

    // Check for rapid successive uploads
    final sortedHistory = List<DateTime>.from(uploadHistory)
      ..sort((a, b) => b.compareTo(a));

    int rapidUploads = 0;
    for (int i = 0; i < sortedHistory.length - 1; i++) {
      final diff = sortedHistory[i].difference(sortedHistory[i + 1]).inSeconds;
      if (diff < 30) {
        rapidUploads++;
      }
    }

    if (rapidUploads > 3) {
      return SuspiciousActivityResult(
        isSuspicious: true,
        reason: 'Unusually rapid uploads detected',
        trustScore: 0.5,
      );
    }

    // Check for suspicious consistency (all uploads at exact same time)
    final hours = uploadHistory.map((d) => d.hour).toSet();
    if (hours.length == 1 && uploadHistory.length > 5) {
      return SuspiciousActivityResult(
        isSuspicious: true,
        reason: 'Suspicious upload pattern detected',
        trustScore: 0.7,
      );
    }

    return SuspiciousActivityResult(
      isSuspicious: false,
      trustScore: 1.0,
    );
  }

  /// Calculate trust score based on user behavior
  static double calculateTrustScore(
    int totalUploads,
    int daysSinceStart,
    int challengesCompleted,
  ) {
    if (daysSinceStart == 0) return 0.5;

    double score = 0.5; // Start at neutral

    // Consistent usage increases trust
    final uploadRate = totalUploads / daysSinceStart;
    if (uploadRate > 0.3 && uploadRate < 3) {
      score += 0.2;
    }

    // Challenge completion increases trust
    final challengeRate = challengesCompleted / daysSinceStart;
    if (challengeRate > 0.5) {
      score += 0.2;
    }

    // Longevity increases trust
    if (daysSinceStart > 14) {
      score += 0.1;
    }
    if (daysSinceStart > 30) {
      score += 0.1;
    }

    return score.clamp(0.0, 1.0);
  }

  /// Reset rate limiting (for testing)
  static void reset() {
    _recentUploads.clear();
  }

  /// Get remaining uploads for current hour
  static int getRemainingHourlyUploads() {
    final now = DateTime.now();
    final hourAgo = now.subtract(const Duration(hours: 1));
    final uploadsLastHour =
        _recentUploads.where((t) => t.isAfter(hourAgo)).length;
    return AppConstants.maxUploadsPerHour - uploadsLastHour;
  }

  /// Get remaining uploads for today
  static int getRemainingDailyUploads() {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final uploadsToday =
        _recentUploads.where((t) => t.isAfter(dayStart)).length;
    return AppConstants.maxUploadsPerDay - uploadsToday;
  }
}

/// Rate limit check result
class RateLimitResult {
  final bool allowed;
  final String? reason;
  final int? waitMinutes;

  RateLimitResult({
    required this.allowed,
    this.reason,
    this.waitMinutes,
  });
}

/// Suspicious activity check result
class SuspiciousActivityResult {
  final bool isSuspicious;
  final String? reason;
  final double trustScore;

  SuspiciousActivityResult({
    required this.isSuspicious,
    this.reason,
    this.trustScore = 1.0,
  });
}
