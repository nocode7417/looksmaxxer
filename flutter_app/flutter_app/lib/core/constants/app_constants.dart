/// App-wide constants matching the original Looksmaxxer configuration
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Looksmaxxer';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Track your facial metrics over time with evidence-based methodology. '
      'Features orthotropic exercises and honest scientific assessments.';

  // Mental Health Thresholds
  static const int maxDailyAnalyses = 5;
  static const int maxWeeklyAnalyses = 20;
  static const int warningConsecutiveDays = 7;

  // Multi-Frame Analysis
  static const int multiFrameTargetCount = 10;
  static const double multiFrameUncertaintyMm = 1.0;
  static const double singleFrameUncertaintyMm = 3.0;

  // Storage Keys
  static const String hasCompletedOnboardingKey = 'hasCompletedOnboarding';
  static const String baselinePhotoIdKey = 'baselinePhotoId';
  static const String baselineDateKey = 'baselineDate';
  static const String metricsKey = 'metrics';
  static const String timelineKey = 'timeline';
  static const String challengesKey = 'challenges';
  static const String challengeStreakKey = 'challengeStreak';
  static const String lastChallengeDateKey = 'lastChallengeDate';
  static const String progressScoreKey = 'progressScore';
  static const String progressUnlockedAtKey = 'progressUnlockedAt';
  static const String settingsKey = 'settings';
  static const String createdAtKey = 'createdAt';

  // Database
  static const String databaseName = 'looksmaxxer.db';
  static const int databaseVersion = 1;
  static const String photosTable = 'photos';

  // Progress Unlock Requirements
  static const int minDaysForProgress = 14;
  static const int minPhotosForProgress = 7;
  static const int minChallengesForProgress = 5;

  // Quality Thresholds
  static const double minQualityScore = 50.0;
  static const double optimalBrightnessMin = 40.0;
  static const double optimalBrightnessMax = 120.0;

  // Rate Limiting
  static const int maxUploadsPerHour = 10;
  static const int maxUploadsPerDay = 20;

  // Analysis
  static const int analysisDelayMinMs = 2000;
  static const int analysisDelayMaxMs = 3500;

  // Scoring Weights
  static const double consistencyWeight = 0.35;
  static const double challengeCompletionWeight = 0.25;
  static const double photoQualityWeight = 0.20;
  static const double improvementWeight = 0.20;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 400);
  static const Duration staggerDelay = Duration(milliseconds: 80);

  // Camera
  static const double cameraAspectRatio = 9 / 16;
}

/// Metric names and their configurations
class MetricConfig {
  final String id;
  final String name;
  final String description;
  final double minValue;
  final double maxValue;
  final String unit;
  final List<String> factors;
  final bool higherIsBetter;

  const MetricConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.minValue,
    required this.maxValue,
    required this.unit,
    required this.factors,
    this.higherIsBetter = true,
  });

  static const List<MetricConfig> allMetrics = [
    MetricConfig(
      id: 'facialSymmetry',
      name: 'Facial Symmetry',
      description: 'Bilateral feature comparison measuring left-right alignment',
      minValue: 0,
      maxValue: 100,
      unit: '',
      factors: ['Sleep', 'Hydration', 'Stress', 'Posture'],
    ),
    MetricConfig(
      id: 'proportionalHarmony',
      name: 'Proportional Harmony',
      description: 'Facial thirds ratio analysis measuring vertical proportions',
      minValue: -15,
      maxValue: 15,
      unit: '',
      factors: ['Camera angle', 'Expression', 'Head tilt'],
      higherIsBetter: false, // Closer to 0 is better
    ),
    MetricConfig(
      id: 'canthalTilt',
      name: 'Canthal Tilt',
      description: 'Inner/outer eye corner angle measurement',
      minValue: -10,
      maxValue: 15,
      unit: '\u00B0',
      factors: ['Sleep', 'Fluid retention', 'Age'],
    ),
    MetricConfig(
      id: 'skinTexture',
      name: 'Skin Texture',
      description: 'Surface uniformity and hydration level assessment',
      minValue: 0,
      maxValue: 100,
      unit: '',
      factors: ['Hydration', 'Sleep', 'Skincare', 'Diet', 'Stress'],
    ),
    MetricConfig(
      id: 'skinClarity',
      name: 'Skin Clarity',
      description: 'Pigmentation evenness and inflammation measurement',
      minValue: 0,
      maxValue: 100,
      unit: '',
      factors: ['Sun exposure', 'Skincare', 'Diet', 'Hormones'],
    ),
    MetricConfig(
      id: 'jawDefinition',
      name: 'Jaw Definition',
      description: 'Mandibular contour sharpness assessment',
      minValue: 0,
      maxValue: 100,
      unit: '',
      factors: ['Body fat', 'Posture', 'Mewing', 'Hydration'],
    ),
    MetricConfig(
      id: 'cheekboneProminence',
      name: 'Cheekbone Prominence',
      description: 'Zygomatic projection measurement',
      minValue: 0,
      maxValue: 100,
      unit: '',
      factors: ['Lighting', 'Body fat', 'Facial exercises'],
    ),
  ];

  static MetricConfig? getById(String id) {
    try {
      return allMetrics.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
