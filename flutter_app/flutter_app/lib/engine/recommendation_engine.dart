import '../data/models/geometry_metrics_model.dart';
import '../data/models/orthotropic_exercise_model.dart';
import '../data/models/photo_model.dart';

/// Personalized recommendation based on analysis
class Recommendation {
  final OrthotropicExercise exercise;
  final String? detectedIssue;
  final double relevanceScore; // 0-100
  final String personalizedMessage;
  final List<String> disclaimers;

  const Recommendation({
    required this.exercise,
    this.detectedIssue,
    required this.relevanceScore,
    required this.personalizedMessage,
    this.disclaimers = const [],
  });
}

/// Engine for generating personalized recommendations
class RecommendationEngine {
  /// Generate recommendations based on analysis results and user age
  static List<Recommendation> generateRecommendations({
    required Map<String, MetricValue> metrics,
    GeometryAnalysisResult? geometryAnalysis,
    int? userAge,
  }) {
    final recommendations = <Recommendation>[];

    // Get age-appropriate exercises
    final exercises = userAge != null
        ? OrthotropicExerciseRepository.getForAge(userAge)
        : OrthotropicExerciseRepository.allExercises;

    // Always recommend hydration (strongest evidence)
    final hydrationExercise = exercises.firstWhere(
      (e) => e.id == 'hydration_daily',
      orElse: () => OrthotropicExerciseRepository.allExercises.first,
    );
    recommendations.add(Recommendation(
      exercise: hydrationExercise,
      relevanceScore: 95,
      personalizedMessage: 'Track your water intake for improved skin health.',
      disclaimers: [],
    ));

    // Check for posture-related recommendations
    _addPostureRecommendations(
      recommendations,
      metrics,
      geometryAnalysis,
      exercises,
      userAge,
    );

    // Check for jaw-related recommendations
    _addJawRecommendations(
      recommendations,
      metrics,
      geometryAnalysis,
      exercises,
      userAge,
    );

    // Check for breathing recommendations
    _addBreathingRecommendations(
      recommendations,
      exercises,
      userAge,
    );

    // Sort by relevance and evidence strength
    recommendations.sort((a, b) {
      // Primary sort by evidence strength
      final evidenceOrder = {
        EvidenceStrength.strong: 0,
        EvidenceStrength.moderate: 1,
        EvidenceStrength.limited: 2,
        EvidenceStrength.none: 3,
      };
      final evidenceCompare = evidenceOrder[a.exercise.evidenceStrength]!
          .compareTo(evidenceOrder[b.exercise.evidenceStrength]!);
      if (evidenceCompare != 0) return evidenceCompare;

      // Secondary sort by relevance score
      return b.relevanceScore.compareTo(a.relevanceScore);
    });

    return recommendations;
  }

  static void _addPostureRecommendations(
    List<Recommendation> recommendations,
    Map<String, MetricValue> metrics,
    GeometryAnalysisResult? geometryAnalysis,
    List<OrthotropicExercise> exercises,
    int? userAge,
  ) {
    // Chin tucks - always relevant, strong evidence
    final chinTucks = exercises.cast<OrthotropicExercise?>().firstWhere(
          (e) => e?.id == 'chin_tucks',
          orElse: () => null,
        );

    if (chinTucks != null) {
      recommendations.add(Recommendation(
        exercise: chinTucks,
        detectedIssue: 'Forward head posture affects profile appearance',
        relevanceScore: 90,
        personalizedMessage:
            'Chin tucks improve profile appearance and reduce neck strain. '
            'This is one of the most impactful exercises you can do.',
        disclaimers: [
          'Stop if you experience any neck pain.',
        ],
      ));
    }

    // Forward head posture correction
    final fhpCorrection = exercises.cast<OrthotropicExercise?>().firstWhere(
          (e) => e?.id == 'fhp_correction',
          orElse: () => null,
        );

    if (fhpCorrection != null) {
      recommendations.add(Recommendation(
        exercise: fhpCorrection,
        relevanceScore: 85,
        personalizedMessage:
            'Comprehensive posture work can significantly improve how you '
            'look from the side in photos.',
        disclaimers: [],
      ));
    }
  }

  static void _addJawRecommendations(
    List<Recommendation> recommendations,
    Map<String, MetricValue> metrics,
    GeometryAnalysisResult? geometryAnalysis,
    List<OrthotropicExercise> exercises,
    int? userAge,
  ) {
    final jawDefinition = metrics['jawDefinition'];

    // Masseter training - moderate evidence
    final masseterTraining = exercises.cast<OrthotropicExercise?>().firstWhere(
          (e) => e?.id == 'masseter_chewing',
          orElse: () => null,
        );

    if (masseterTraining != null) {
      String personalizedMessage;
      double relevanceScore;

      if (jawDefinition != null && jawDefinition.value < 60) {
        personalizedMessage =
            'Your jaw muscle definition could potentially improve with '
            'targeted chewing exercises. Remember: this builds muscle, '
            'not bone structure.';
        relevanceScore = 80;
      } else {
        personalizedMessage =
            'Chewing exercises can help maintain or improve jaw muscle '
            'definition. Effects are from muscle hypertrophy, not bone changes.';
        relevanceScore = 65;
      }

      recommendations.add(Recommendation(
        exercise: masseterTraining,
        detectedIssue: jawDefinition != null && jawDefinition.value < 60
            ? 'Lower jaw muscle definition detected'
            : null,
        relevanceScore: relevanceScore,
        personalizedMessage: personalizedMessage,
        disclaimers: [
          'Stop immediately if you experience TMJ pain or clicking.',
          'Muscle growth is confirmed, bone structure changes are not.',
        ],
      ));
    }

    // Mewing - limited evidence, but popular with Gen Z
    final mewing = exercises.cast<OrthotropicExercise?>().firstWhere(
          (e) => e?.id == 'mewing_basic',
          orElse: () => null,
        );

    if (mewing != null) {
      final isTeenager = userAge != null && userAge >= 13 && userAge <= 18;

      recommendations.add(Recommendation(
        exercise: mewing,
        relevanceScore: isTeenager ? 70 : 50,
        personalizedMessage: isTeenager
            ? 'Tongue posture may have some influence during active growth '
                'years. Limited evidence, but low risk if done gently.'
            : 'Tongue posture is popular in looksmaxxing communities, but '
                'evidence for facial changes in adults is minimal. May still '
                'help with posture and swallowing patterns.',
        disclaimers: [
          'Evidence for bone changes is extremely limited.',
          'Do not apply excessive pressure.',
          'Most facial growth occurs before age 18.',
        ],
      ));
    }
  }

  static void _addBreathingRecommendations(
    List<Recommendation> recommendations,
    List<OrthotropicExercise> exercises,
    int? userAge,
  ) {
    final noseBreathing = exercises.cast<OrthotropicExercise?>().firstWhere(
          (e) => e?.id == 'nose_breathing',
          orElse: () => null,
        );

    if (noseBreathing != null) {
      recommendations.add(Recommendation(
        exercise: noseBreathing,
        relevanceScore: 75,
        personalizedMessage:
            'Nasal breathing has numerous health benefits beyond facial '
            'appearance, including better sleep and air filtration.',
        disclaimers: [
          'If you cannot breathe through your nose, consult an ENT specialist.',
        ],
      ));
    }
  }

  /// Check if a recommendation is safe for the given age
  static bool isSafeForAge(OrthotropicExercise exercise, int age) {
    if (exercise.minAgeRecommended != null &&
        age < exercise.minAgeRecommended!) {
      return false;
    }
    if (exercise.maxAgeRecommended != null &&
        age > exercise.maxAgeRecommended!) {
      return false;
    }
    return true;
  }

  /// Get medical disclaimer for recommendations
  static String getMedicalDisclaimer(int? userAge) {
    if (userAge != null && userAge < 18) {
      return 'These exercises are not medical treatment. Talk to a parent or '
          'guardian about any concerns. See a doctor if you experience pain.';
    }
    return 'These exercises are not medical treatment. Consult a healthcare '
        'provider if you have concerns or experience pain.';
  }

  /// Get all exercises filtered by safety
  static List<OrthotropicExercise> getSafeExercises(int? userAge) {
    if (userAge == null) {
      return OrthotropicExerciseRepository.allExercises;
    }

    return OrthotropicExerciseRepository.allExercises
        .where((e) => isSafeForAge(e, userAge))
        .toList();
  }

  /// Check if a practice is banned
  static bool isPracticeBanned(String practiceName) {
    return BannedPractices.isBanned(practiceName);
  }

  /// Get warning for banned practice
  static String? getBannedPracticeWarning(String practiceName) {
    return BannedPractices.getWarningMessage(practiceName);
  }
}

/// Formatter for displaying recommendations with evidence labels
class RecommendationFormatter {
  /// Format recommendation with evidence label
  static String formatWithEvidence(Recommendation recommendation) {
    final exercise = recommendation.exercise;
    final evidenceLabel = _getEvidenceLabel(exercise.evidenceStrength);

    return '''
$evidenceLabel ${exercise.name}

${recommendation.personalizedMessage}

Theory: ${exercise.theory}

Evidence Assessment: ${exercise.honestAssessment}

How to:
${exercise.howToSteps.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n')}

${exercise.frequency != null ? 'Frequency: ${exercise.frequency}' : ''}
${exercise.duration != null ? 'Duration: ${exercise.duration}' : ''}

${recommendation.disclaimers.isNotEmpty ? 'Important:\n${recommendation.disclaimers.map((d) => '- $d').join('\n')}' : ''}
''';
  }

  static String _getEvidenceLabel(EvidenceStrength strength) {
    switch (strength) {
      case EvidenceStrength.strong:
        return '\u2713 STRONG EVIDENCE:';
      case EvidenceStrength.moderate:
        return '\u2248 MODERATE EVIDENCE:';
      case EvidenceStrength.limited:
        return '\u26A0 LIMITED EVIDENCE:';
      case EvidenceStrength.none:
        return '\u2717 NO EVIDENCE:';
    }
  }

  /// Get color for evidence strength
  static String getEvidenceColor(EvidenceStrength strength) {
    switch (strength) {
      case EvidenceStrength.strong:
        return 'success'; // Green
      case EvidenceStrength.moderate:
        return 'info'; // Blue
      case EvidenceStrength.limited:
        return 'warning'; // Orange/Yellow
      case EvidenceStrength.none:
        return 'error'; // Red
    }
  }
}
