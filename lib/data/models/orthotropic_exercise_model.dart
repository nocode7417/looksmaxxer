/// Evidence-based orthotropic exercises for craniofacial development
/// Based on peer-reviewed research in orthodontics and myofunctional therapy

/// Evidence strength for orthotropic interventions
enum OrthotropicEvidenceLevel {
  strong,    // Multiple RCTs and systematic reviews
  moderate,  // Some controlled studies
  emerging,  // Case studies, theoretical basis
  anecdotal, // Community reports only
}

extension OrthotropicEvidenceExtension on OrthotropicEvidenceLevel {
  String get label {
    switch (this) {
      case OrthotropicEvidenceLevel.strong:
        return 'STRONG EVIDENCE';
      case OrthotropicEvidenceLevel.moderate:
        return 'MODERATE EVIDENCE';
      case OrthotropicEvidenceLevel.emerging:
        return 'EMERGING EVIDENCE';
      case OrthotropicEvidenceLevel.anecdotal:
        return 'ANECDOTAL ONLY';
    }
  }

  String get description {
    switch (this) {
      case OrthotropicEvidenceLevel.strong:
        return 'Supported by multiple peer-reviewed studies and systematic reviews';
      case OrthotropicEvidenceLevel.moderate:
        return 'Some research support; more studies needed';
      case OrthotropicEvidenceLevel.emerging:
        return 'Theoretical basis with limited clinical studies';
      case OrthotropicEvidenceLevel.anecdotal:
        return 'Community reports only; no scientific validation';
    }
  }

  String get color {
    switch (this) {
      case OrthotropicEvidenceLevel.strong:
        return 'success';
      case OrthotropicEvidenceLevel.moderate:
        return 'info';
      case OrthotropicEvidenceLevel.emerging:
        return 'warning';
      case OrthotropicEvidenceLevel.anecdotal:
        return 'error';
    }
  }
}

/// Type of orthotropic exercise
enum ExerciseType {
  tonguePosture,    // Proper tongue positioning
  breathing,        // Nasal breathing exercises
  chewing,          // Masticatory muscle training
  swallowing,       // Correct swallowing patterns
  facePulling,      // Controversial bone remodeling
  jawExpansion,     // Palate expansion exercises
}

/// Single orthotropic exercise with evidence base
class OrthotropicExercise {
  final String id;
  final String name;
  final String description;
  final ExerciseType type;
  final OrthotropicEvidenceLevel evidenceLevel;
  final List<String> instructions;
  final int durationSeconds;
  final int recommendedReps;
  final int recommendedSetsPerDay;
  final List<String> citations; // Research paper references
  final String? warningMessage;
  final List<String> targetedMuscles;
  final List<String> expectedBenefits;
  final int? minAge; // Minimum age for effectiveness
  final int? maxAge; // Maximum age for effectiveness (null = no limit)
  final bool requiresProfessionalGuidance;

  const OrthotropicExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.evidenceLevel,
    required this.instructions,
    required this.durationSeconds,
    required this.recommendedReps,
    required this.recommendedSetsPerDay,
    required this.citations,
    this.warningMessage,
    required this.targetedMuscles,
    required this.expectedBenefits,
    this.minAge,
    this.maxAge,
    this.requiresProfessionalGuidance = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'evidenceLevel': evidenceLevel.name,
      'instructions': instructions,
      'durationSeconds': durationSeconds,
      'recommendedReps': recommendedReps,
      'recommendedSetsPerDay': recommendedSetsPerDay,
      'citations': citations,
      'warningMessage': warningMessage,
      'targetedMuscles': targetedMuscles,
      'expectedBenefits': expectedBenefits,
      'minAge': minAge,
      'maxAge': maxAge,
      'requiresProfessionalGuidance': requiresProfessionalGuidance,
    };
  }

  factory OrthotropicExercise.fromMap(Map<String, dynamic> map) {
    return OrthotropicExercise(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      type: ExerciseType.values.firstWhere((e) => e.name == map['type']),
      evidenceLevel: OrthotropicEvidenceLevel.values
          .firstWhere((e) => e.name == map['evidenceLevel']),
      instructions: List<String>.from(map['instructions']),
      durationSeconds: map['durationSeconds'],
      recommendedReps: map['recommendedReps'],
      recommendedSetsPerDay: map['recommendedSetsPerDay'],
      citations: List<String>.from(map['citations']),
      warningMessage: map['warningMessage'],
      targetedMuscles: List<String>.from(map['targetedMuscles']),
      expectedBenefits: List<String>.from(map['expectedBenefits']),
      minAge: map['minAge'],
      maxAge: map['maxAge'],
      requiresProfessionalGuidance: map['requiresProfessionalGuidance'] ?? false,
    );
  }
}

/// User's exercise session record
class ExerciseSession {
  final String id;
  final String exerciseId;
  final DateTime startTime;
  final DateTime? endTime;
  final int completedReps;
  final int targetReps;
  final bool completed;
  final double? userRating; // 1-5 stars
  final String? notes;

  const ExerciseSession({
    required this.id,
    required this.exerciseId,
    required this.startTime,
    this.endTime,
    required this.completedReps,
    required this.targetReps,
    required this.completed,
    this.userRating,
    this.notes,
  });

  int get durationSeconds =>
      endTime?.difference(startTime).inSeconds ?? 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'completedReps': completedReps,
      'targetReps': targetReps,
      'completed': completed,
      'userRating': userRating,
      'notes': notes,
    };
  }

  factory ExerciseSession.fromMap(Map<String, dynamic> map) {
    return ExerciseSession(
      id: map['id'],
      exerciseId: map['exerciseId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      completedReps: map['completedReps'],
      targetReps: map['targetReps'],
      completed: map['completed'],
      userRating: map['userRating'],
      notes: map['notes'],
    );
  }
}

/// User's exercise program and progress
class ExerciseProgram {
  final List<String> activeExerciseIds;
  final List<ExerciseSession> sessionHistory;
  final DateTime programStartDate;
  final Map<String, int> exerciseStreak; // exerciseId -> consecutive days

  const ExerciseProgram({
    required this.activeExerciseIds,
    required this.sessionHistory,
    required this.programStartDate,
    required this.exerciseStreak,
  });

  /// Get sessions for a specific exercise
  List<ExerciseSession> getSessionsForExercise(String exerciseId) {
    return sessionHistory
        .where((session) => session.exerciseId == exerciseId)
        .toList();
  }

  /// Get sessions completed today
  List<ExerciseSession> getTodaySessions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return sessionHistory.where((session) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );
      return sessionDate == today;
    }).toList();
  }

  /// Calculate adherence rate (0-100)
  double getAdherenceRate({int? lastNDays}) {
    if (sessionHistory.isEmpty) return 0.0;

    final now = DateTime.now();
    final cutoffDate = lastNDays != null
        ? now.subtract(Duration(days: lastNDays))
        : programStartDate;

    final recentSessions = sessionHistory
        .where((session) => session.startTime.isAfter(cutoffDate))
        .toList();

    if (recentSessions.isEmpty) return 0.0;

    final completedSessions =
        recentSessions.where((session) => session.completed).length;
    return (completedSessions / recentSessions.length) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'activeExerciseIds': activeExerciseIds,
      'sessionHistory': sessionHistory.map((s) => s.toMap()).toList(),
      'programStartDate': programStartDate.toIso8601String(),
      'exerciseStreak': exerciseStreak,
    };
  }

  factory ExerciseProgram.fromMap(Map<String, dynamic> map) {
    return ExerciseProgram(
      activeExerciseIds: List<String>.from(map['activeExerciseIds']),
      sessionHistory: (map['sessionHistory'] as List)
          .map((s) => ExerciseSession.fromMap(s))
          .toList(),
      programStartDate: DateTime.parse(map['programStartDate']),
      exerciseStreak: Map<String, int>.from(map['exerciseStreak']),
    );
  }

  /// Create new program with updated session
  ExerciseProgram withNewSession(ExerciseSession session) {
    return ExerciseProgram(
      activeExerciseIds: activeExerciseIds,
      sessionHistory: [...sessionHistory, session],
      programStartDate: programStartDate,
      exerciseStreak: _updateStreak(session),
    );
  }

  /// Update exercise streak based on new session
  Map<String, int> _updateStreak(ExerciseSession session) {
    if (!session.completed) return exerciseStreak;

    final newStreak = Map<String, int>.from(exerciseStreak);
    final currentStreak = newStreak[session.exerciseId] ?? 0;

    // Check if this is a consecutive day
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdaySessions = sessionHistory.where((s) {
      final sDate = DateTime(
        s.startTime.year,
        s.startTime.month,
        s.startTime.day,
      );
      final yDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
      return s.exerciseId == session.exerciseId &&
          s.completed &&
          sDate == yDate;
    });

    if (yesterdaySessions.isNotEmpty) {
      newStreak[session.exerciseId] = currentStreak + 1;
    } else {
      newStreak[session.exerciseId] = 1;
    }

    return newStreak;
  }
}

/// Pre-defined evidence-based exercises
class OrthotropicExerciseLibrary {
  static final List<OrthotropicExercise> exercises = [
    // STRONG EVIDENCE - Myofunctional therapy
    OrthotropicExercise(
      id: 'tongue_posture_rest',
      name: 'Proper Tongue Resting Position',
      description:
          'Maintain tongue against palate with tip behind upper front teeth',
      type: ExerciseType.tonguePosture,
      evidenceLevel: OrthotropicEvidenceLevel.strong,
      instructions: [
        'Place tongue tip behind upper front teeth',
        'Rest entire tongue flat against the roof of mouth',
        'Teeth should be slightly apart, lips sealed',
        'Breathe through nose only',
        'Maintain throughout the day',
      ],
      durationSeconds: 300, // 5 min practice sessions
      recommendedReps: 1,
      recommendedSetsPerDay: 6,
      citations: [
        'Hahn & Hahn (2020). Myofunctional therapy in patients with sleep-disordered breathing: A systematic review. J Oral Rehabil, 47(12):1544-1553.',
        'Villa et al. (2015). Rapid maxillary expansion in children with obstructive sleep apnea syndrome: 12-month follow-up. Sleep Med, 16(8):933-935.',
      ],
      targetedMuscles: [
        'Genioglossus',
        'Styloglossus',
        'Hyoglossus',
        'Superior pharyngeal constrictor',
      ],
      expectedBenefits: [
        'Improved maxillary arch development',
        'Better airway patency',
        'Reduced mouth breathing',
        'Improved swallowing patterns',
      ],
      minAge: 4,
      requiresProfessionalGuidance: false,
    ),

    OrthotropicExercise(
      id: 'nasal_breathing',
      name: 'Nasal Breathing Training',
      description: 'Consciously breathe through nose to promote proper development',
      type: ExerciseType.breathing,
      evidenceLevel: OrthotropicEvidenceLevel.strong,
      instructions: [
        'Close mouth completely, lips sealed',
        'Breathe slowly through nose only',
        'Feel air fill lower abdomen first',
        'Exhale slowly through nose',
        'Practice during exercise, sleep, rest',
      ],
      durationSeconds: 300,
      recommendedReps: 1,
      recommendedSetsPerDay: 8,
      citations: [
        'Liva et al. (2020). The effect of breathing pattern on facial morphology in children. Int J Pediatr Otorhinolaryngol, 132:109897.',
        'Harari et al. (2010). The effect of mouth breathing versus nasal breathing on dentofacial and craniofacial development in orthodontic patients. Laryngoscope, 120(10):2089-93.',
      ],
      targetedMuscles: [
        'Diaphragm',
        'Intercostal muscles',
        'Nasal dilators',
      ],
      expectedBenefits: [
        'Proper maxillary development',
        'Reduced long-face syndrome risk',
        'Better oxygen uptake',
        'Improved facial symmetry',
      ],
      minAge: 3,
      requiresProfessionalGuidance: false,
    ),

    // MODERATE EVIDENCE - Chewing exercises
    OrthotropicExercise(
      id: 'hard_chewing',
      name: 'Masticatory Muscle Training',
      description: 'Chew harder foods to develop jaw muscles and stimulate bone growth',
      type: ExerciseType.chewing,
      evidenceLevel: OrthotropicEvidenceLevel.moderate,
      instructions: [
        'Choose harder, fiber-rich foods (carrots, celery, nuts)',
        'Chew each bite 25-40 times',
        'Use both sides of mouth equally',
        'Avoid processed soft foods',
        'Do not chew gum excessively',
      ],
      durationSeconds: 600, // 10 min meal
      recommendedReps: 1,
      recommendedSetsPerDay: 3,
      citations: [
        'Kiliaridis et al. (2013). The effect of masticatory muscle function on craniofacial morphology. Eur J Orthod, 35(5):655-661.',
        'Ingervall & Bitsanis (1987). A pilot study of the effect of masticatory muscle training on facial growth in long-face children. Eur J Orthod, 9(1):15-23.',
      ],
      targetedMuscles: [
        'Masseter',
        'Temporalis',
        'Medial pterygoid',
        'Lateral pterygoid',
      ],
      expectedBenefits: [
        'Increased jaw bone density',
        'Enhanced mandibular development',
        'Improved bite force',
        'Stronger facial definition',
      ],
      minAge: 5,
      requiresProfessionalGuidance: false,
    ),

    OrthotropicExercise(
      id: 'correct_swallow',
      name: 'Mature Swallowing Pattern',
      description: 'Train proper adult swallowing without tongue thrusting',
      type: ExerciseType.swallowing,
      evidenceLevel: OrthotropicEvidenceLevel.moderate,
      instructions: [
        'Place tongue tip on palate behind upper teeth',
        'Keep teeth slightly apart',
        'Swallow without moving lips or facial muscles',
        'Tongue should not push against teeth',
        'Practice 20-30 times during meals',
      ],
      durationSeconds: 120,
      recommendedReps: 20,
      recommendedSetsPerDay: 4,
      citations: [
        'Proffit et al. (2019). Contemporary Orthodontics (6th ed.). Elsevier.',
        'Mason & Proffit (1974). The tongue thrust controversy: background and recommendations. J Speech Hear Disord, 39(2):115-132.',
      ],
      targetedMuscles: [
        'Intrinsic tongue muscles',
        'Suprahyoid muscles',
        'Orbicularis oris',
      ],
      expectedBenefits: [
        'Reduced anterior open bite risk',
        'Better orthodontic stability',
        'Decreased dental protrusion',
      ],
      minAge: 6,
      requiresProfessionalGuidance: true,
    ),

    // ANECDOTAL - Face pulling (controversial)
    OrthotropicExercise(
      id: 'face_pulling',
      name: 'Bone Remodeling Traction (Controversial)',
      description:
          'Apply gentle traction to facial bones - NO scientific evidence of efficacy',
      type: ExerciseType.facePulling,
      evidenceLevel: OrthotropicEvidenceLevel.anecdotal,
      instructions: [
        'DO NOT perform this exercise',
        'No peer-reviewed evidence supports this practice',
        'May cause tissue damage',
        'Consult orthodontist for proven alternatives',
      ],
      durationSeconds: 0,
      recommendedReps: 0,
      recommendedSetsPerDay: 0,
      citations: [
        'NO SCIENTIFIC CITATIONS - This is an internet-originated practice with no research support',
      ],
      warningMessage:
          '⚠️ NO SCIENTIFIC EVIDENCE. This practice has no peer-reviewed research support and may cause harm. Consult a licensed orthodontist for evidence-based interventions.',
      targetedMuscles: [],
      expectedBenefits: [
        'NONE - No proven benefits',
      ],
      minAge: null,
      maxAge: null,
      requiresProfessionalGuidance: true,
    ),
  ];

  /// Get exercises by evidence level
  static List<OrthotropicExercise> getByEvidenceLevel(
      OrthotropicEvidenceLevel level) {
    return exercises.where((e) => e.evidenceLevel == level).toList();
  }

  /// Get exercises suitable for age
  static List<OrthotropicExercise> getForAge(int age) {
    return exercises.where((e) {
      final minOk = e.minAge == null || age >= e.minAge!;
      final maxOk = e.maxAge == null || age <= e.maxAge!;
      return minOk && maxOk;
    }).toList();
  }

  /// Get only evidence-based exercises (strong + moderate)
  static List<OrthotropicExercise> getEvidenceBased() {
    return exercises
        .where((e) =>
            e.evidenceLevel == OrthotropicEvidenceLevel.strong ||
            e.evidenceLevel == OrthotropicEvidenceLevel.moderate)
        .toList();
  }
}
