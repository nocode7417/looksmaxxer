import 'geometry_metrics_model.dart';

/// Categories for Gen Z orthotropic/looksmaxxing exercises
enum ExerciseCategory {
  hydration,
  tonguePosture,   // Mewing
  masseterTraining, // Hard chewing
  postureCorrection, // Chin tucks, head posture
  breathing,        // Nose breathing
}

extension ExerciseCategoryExtension on ExerciseCategory {
  String get displayName {
    switch (this) {
      case ExerciseCategory.hydration:
        return 'Hydration';
      case ExerciseCategory.tonguePosture:
        return 'Tongue Posture';
      case ExerciseCategory.masseterTraining:
        return 'Jaw Training';
      case ExerciseCategory.postureCorrection:
        return 'Posture';
      case ExerciseCategory.breathing:
        return 'Breathing';
    }
  }

  String get icon {
    switch (this) {
      case ExerciseCategory.hydration:
        return '\u{1F4A7}'; // Water drop
      case ExerciseCategory.tonguePosture:
        return '\u{1F445}'; // Tongue
      case ExerciseCategory.masseterTraining:
        return '\u{1F4AA}'; // Muscle
      case ExerciseCategory.postureCorrection:
        return '\u{1F9D8}'; // Yoga pose
      case ExerciseCategory.breathing:
        return '\u{1F4A8}'; // Wind
    }
  }
}

/// Scientific citation for exercise recommendations
class ScientificCitation {
  final String authors;
  final int year;
  final String title;
  final String journal;
  final String? doi;
  final String? pubmedId;
  final String summary;

  const ScientificCitation({
    required this.authors,
    required this.year,
    required this.title,
    required this.journal,
    this.doi,
    this.pubmedId,
    required this.summary,
  });

  String get formattedCitation =>
      '$authors ($year). "$title." $journal.';

  Map<String, dynamic> toMap() {
    return {
      'authors': authors,
      'year': year,
      'title': title,
      'journal': journal,
      'doi': doi,
      'pubmedId': pubmedId,
      'summary': summary,
    };
  }

  factory ScientificCitation.fromMap(Map<String, dynamic> map) {
    return ScientificCitation(
      authors: map['authors'],
      year: map['year'],
      title: map['title'],
      journal: map['journal'],
      doi: map['doi'],
      pubmedId: map['pubmedId'],
      summary: map['summary'],
    );
  }
}

/// Orthotropic exercise with evidence assessment
class OrthotropicExercise {
  final String id;
  final ExerciseCategory category;
  final String name;
  final String description;
  final String theory;
  final EvidenceStrength evidenceStrength;
  final String honestAssessment;
  final List<String> howToSteps;
  final String? duration;
  final String? frequency;
  final List<ScientificCitation> citations;
  final List<String> warnings;
  final bool requiresMedicalDisclaimer;
  final int? minAgeRecommended;
  final int? maxAgeRecommended;

  const OrthotropicExercise({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.theory,
    required this.evidenceStrength,
    required this.honestAssessment,
    required this.howToSteps,
    this.duration,
    this.frequency,
    this.citations = const [],
    this.warnings = const [],
    this.requiresMedicalDisclaimer = true,
    this.minAgeRecommended,
    this.maxAgeRecommended,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.name,
      'name': name,
      'description': description,
      'theory': theory,
      'evidenceStrength': evidenceStrength.name,
      'honestAssessment': honestAssessment,
      'howToSteps': howToSteps,
      'duration': duration,
      'frequency': frequency,
      'citations': citations.map((c) => c.toMap()).toList(),
      'warnings': warnings,
      'requiresMedicalDisclaimer': requiresMedicalDisclaimer,
      'minAgeRecommended': minAgeRecommended,
      'maxAgeRecommended': maxAgeRecommended,
    };
  }

  factory OrthotropicExercise.fromMap(Map<String, dynamic> map) {
    return OrthotropicExercise(
      id: map['id'],
      category: ExerciseCategory.values.firstWhere(
        (c) => c.name == map['category'],
      ),
      name: map['name'],
      description: map['description'],
      theory: map['theory'],
      evidenceStrength: EvidenceStrength.values.firstWhere(
        (e) => e.name == map['evidenceStrength'],
      ),
      honestAssessment: map['honestAssessment'],
      howToSteps: List<String>.from(map['howToSteps']),
      duration: map['duration'],
      frequency: map['frequency'],
      citations: (map['citations'] as List?)
              ?.map((c) => ScientificCitation.fromMap(c))
              .toList() ??
          [],
      warnings: List<String>.from(map['warnings'] ?? []),
      requiresMedicalDisclaimer: map['requiresMedicalDisclaimer'] ?? true,
      minAgeRecommended: map['minAgeRecommended'],
      maxAgeRecommended: map['maxAgeRecommended'],
    );
  }
}

/// Repository of all orthotropic exercises with evidence-based assessments
class OrthotropicExerciseRepository {
  static const List<OrthotropicExercise> allExercises = [
    // HYDRATION - HIGH EVIDENCE
    OrthotropicExercise(
      id: 'hydration_daily',
      category: ExerciseCategory.hydration,
      name: 'Daily Water Intake',
      description: 'Maintain optimal hydration for skin health and appearance.',
      theory: 'Adequate water intake improves skin turgor, elasticity, and overall appearance.',
      evidenceStrength: EvidenceStrength.strong,
      honestAssessment: 'Multiple controlled studies show measurable skin hydration '
          'improvements with adequate water intake. This is one of the most '
          'evidence-backed recommendations for skin appearance.',
      howToSteps: [
        'Aim for 2-3 liters of water daily',
        'Drink water consistently throughout the day',
        'Start your morning with a glass of water',
        'Reduce excessive caffeine and alcohol which can dehydrate',
        'Eat water-rich foods like fruits and vegetables',
      ],
      duration: 'Ongoing daily habit',
      frequency: 'Daily',
      citations: [
        ScientificCitation(
          authors: 'Palma L, et al.',
          year: 2015,
          title: 'Dietary water affects human skin hydration and biomechanics',
          journal: 'Clinical, Cosmetic and Investigational Dermatology',
          summary: 'Showed that increased water intake improved skin elasticity '
              'and hydration in participants with low baseline water consumption.',
        ),
      ],
      warnings: [],
      requiresMedicalDisclaimer: false,
    ),

    // MEWING / TONGUE POSTURE - LIMITED EVIDENCE
    OrthotropicExercise(
      id: 'mewing_basic',
      category: ExerciseCategory.tonguePosture,
      name: 'Mewing (Tongue Posture)',
      description: 'Maintain proper tongue positioning on the palate throughout the day.',
      theory: 'Consistent tongue positioning on the palate may influence '
          'maxillofacial development during active growth periods.',
      evidenceStrength: EvidenceStrength.limited,
      honestAssessment: 'Theoretical plausibility during active growth phases (under 18). '
          'Extremely limited clinical evidence for facial bone changes. May help '
          'improve swallowing patterns and reduce forward head posture regardless '
          'of facial structure effects.',
      howToSteps: [
        'Rest the entire tongue flat against the roof of your mouth',
        'The tip should be just behind your front teeth (not touching them)',
        'Keep your teeth lightly together or slightly apart',
        'Lips should be sealed without tension',
        'Breathe through your nose',
        'Maintain this position throughout the day, especially when not speaking or eating',
      ],
      duration: 'Throughout the day',
      frequency: 'Constant habit formation',
      citations: [
        ScientificCitation(
          authors: 'Proffit WR, et al.',
          year: 2013,
          title: 'Contemporary Orthodontics',
          journal: 'Elsevier Health Sciences',
          summary: 'Notes that most maxillofacial growth occurs before age 18, '
              'suggesting a potential window for influence during adolescence.',
        ),
        ScientificCitation(
          authors: 'Hanson ML, Mason RM',
          year: 2003,
          title: 'Orofacial Myology: International Perspectives',
          journal: 'Charles C Thomas Publisher',
          summary: 'Discusses myofunctional therapy benefits for swallowing '
              'patterns and orofacial posture.',
        ),
      ],
      warnings: [
        'Do not apply excessive pressure - this should be a relaxed position',
        'If you experience jaw pain or TMJ issues, stop and consult a professional',
        'Bone structure changes are not proven, especially in adults',
      ],
      requiresMedicalDisclaimer: true,
      maxAgeRecommended: 25,
    ),

    // PROPER SWALLOWING
    OrthotropicExercise(
      id: 'proper_swallow',
      category: ExerciseCategory.tonguePosture,
      name: 'Correct Swallow Pattern',
      description: 'Practice the mature swallow pattern instead of tongue thrust.',
      theory: 'Tongue thrust vs. mature swallow pattern may affect facial development '
          'and orofacial muscle function.',
      evidenceStrength: EvidenceStrength.limited,
      honestAssessment: 'Some evidence for myofunctional benefits. Facial structure '
          'changes not robustly proven. May improve overall oral function.',
      howToSteps: [
        'Place tongue tip against the palate behind front teeth',
        'Keep teeth lightly together when swallowing',
        'Push food/liquid back with a wave motion of the tongue',
        'Do not push tongue forward against teeth',
        'Practice with water first, then with food',
      ],
      duration: '5-10 conscious swallows initially',
      frequency: 'Every meal, until habitual',
      citations: [
        ScientificCitation(
          authors: 'Smithpeter J, Covell D',
          year: 2010,
          title: 'Relapse of anterior open bites treated with orthodontic appliances',
          journal: 'Angle Orthodontist',
          summary: 'Discusses myofunctional therapy effects on orofacial posture.',
        ),
      ],
      warnings: [
        'If swallowing is difficult or painful, consult a speech therapist',
      ],
      requiresMedicalDisclaimer: true,
    ),

    // MASSETER TRAINING - MODERATE EVIDENCE
    OrthotropicExercise(
      id: 'masseter_chewing',
      category: ExerciseCategory.masseterTraining,
      name: 'Masseter Training (Chewing)',
      description: 'Increase chewing resistance to strengthen jaw muscles.',
      theory: 'Increased chewing resistance strengthens masseter and temporalis muscles, '
          'potentially improving jaw definition through muscle hypertrophy.',
      evidenceStrength: EvidenceStrength.moderate,
      honestAssessment: 'Muscle hypertrophy is confirmed - jaw muscles respond to '
          'resistance like any other muscle. Bone structure changes are NOT proven. '
          'Can improve jaw definition through increased muscle mass.',
      howToSteps: [
        'Use sugar-free, tough gum (mastic gum or falim gum work well)',
        'Chew evenly on both sides to maintain symmetry',
        'Start with 15-20 minutes daily, gradually increase to 1 hour',
        'Take rest days to prevent TMJ strain',
        'Alternative: Eat harder foods like raw vegetables, nuts, tough meats',
      ],
      duration: '30-60 minutes per day',
      frequency: '5-6 days per week with rest days',
      citations: [
        ScientificCitation(
          authors: 'Kiliaridis S, et al.',
          year: 1985,
          title: 'The relationship between masticatory function and craniofacial morphology',
          journal: 'European Journal of Orthodontics',
          summary: 'Documented masticatory muscle changes in populations with tougher diets.',
        ),
        ScientificCitation(
          authors: 'Watanabe M, et al.',
          year: 2017,
          title: 'Effect of gum-chewing on masseter muscle volume',
          journal: 'Journal of Oral Rehabilitation',
          summary: 'Demonstrated that regular gum chewing increases masseter muscle thickness.',
        ),
      ],
      warnings: [
        'Stop if you experience jaw pain, clicking, or TMJ discomfort',
        'Do not chew excessively - this can cause TMJ disorders',
        'Consult a dentist if you have existing jaw or teeth issues',
        'Will not change bone structure, only muscle definition',
      ],
      requiresMedicalDisclaimer: true,
    ),

    // CHIN TUCKS - STRONG EVIDENCE
    OrthotropicExercise(
      id: 'chin_tucks',
      category: ExerciseCategory.postureCorrection,
      name: 'Chin Tucks',
      description: 'Correct forward head posture for improved profile and neck health.',
      theory: 'Correcting forward head posture improves cervical spine alignment, '
          'reduces neck strain, and enhances profile aesthetics.',
      evidenceStrength: EvidenceStrength.strong,
      honestAssessment: 'Strong evidence for posture improvement and profile aesthetics. '
          'This actually works for improving how your profile looks in photos and '
          'reducing neck/shoulder tension. Well-documented in physical therapy literature.',
      howToSteps: [
        'Stand or sit with your back straight',
        'Look straight ahead, not up or down',
        'Pull your chin straight back (not down) as if making a double chin',
        'Hold for 5-10 seconds',
        'Release and repeat 10-15 times',
        'Perform 3 sets throughout the day',
      ],
      duration: '2-3 minutes per set',
      frequency: '3 times daily',
      citations: [
        ScientificCitation(
          authors: 'Noh DK, et al.',
          year: 2021,
          title: 'The effect of chin tuck exercise on forward head posture',
          journal: 'Healthcare',
          summary: 'Documented improvements in head posture and perceived attractiveness.',
        ),
      ],
      warnings: [
        'Stop if you feel pain in your neck or shoulders',
        'Do not force the movement - it should be gentle',
      ],
      requiresMedicalDisclaimer: false,
    ),

    // FORWARD HEAD POSTURE CORRECTION
    OrthotropicExercise(
      id: 'fhp_correction',
      category: ExerciseCategory.postureCorrection,
      name: 'Forward Head Posture Correction',
      description: 'Comprehensive posture work to align ears over shoulders.',
      theory: 'Modern lifestyle (phones, computers) causes forward head posture '
          'which affects facial profile appearance and neck health.',
      evidenceStrength: EvidenceStrength.strong,
      honestAssessment: 'Excellent evidence for improving posture and profile appearance. '
          'One of the most impactful changes you can make for how you look from the side.',
      howToSteps: [
        'Check posture: ears should align with shoulders when standing',
        'Set hourly reminders to check and correct posture',
        'Raise phone/monitor to eye level to prevent looking down',
        'Strengthen upper back muscles with rows and reverse flies',
        'Stretch chest muscles daily',
        'Sleep with a supportive pillow that maintains neck alignment',
      ],
      duration: 'Ongoing awareness',
      frequency: 'Hourly checks, daily exercises',
      citations: [
        ScientificCitation(
          authors: 'Kang JH, et al.',
          year: 2012,
          title: 'The effect of the forward head posture on postural balance',
          journal: 'Journal of Physical Therapy Science',
          summary: 'Documents effects of FHP and benefits of correction.',
        ),
      ],
      warnings: [],
      requiresMedicalDisclaimer: false,
    ),

    // NOSE BREATHING
    OrthotropicExercise(
      id: 'nose_breathing',
      category: ExerciseCategory.breathing,
      name: 'Nasal Breathing',
      description: 'Breathe through your nose instead of your mouth.',
      theory: 'Chronic mouth breathing during development is associated with '
          'altered facial growth patterns ("long face syndrome").',
      evidenceStrength: EvidenceStrength.moderate,
      honestAssessment: 'Preventive benefits during growth are well-established. '
          'Corrective benefits in teens/young adults are less certain. '
          'Regardless, nasal breathing has numerous health benefits including '
          'better sleep, nitric oxide production, and filtered air.',
      howToSteps: [
        'Close your mouth and breathe through your nose',
        'During exercise, try to maintain nasal breathing as long as possible',
        'At night, consider mouth tape if you mouth breathe during sleep (consult doctor first)',
        'If nasal breathing is difficult, address allergies or congestion',
        'Practice throughout the day until it becomes automatic',
      ],
      duration: 'All day and night',
      frequency: 'Continuous habit',
      citations: [
        ScientificCitation(
          authors: 'Harari D, et al.',
          year: 2010,
          title: 'The effect of mouth breathing versus nasal breathing on dentofacial development',
          journal: 'International Journal of Pediatric Otorhinolaryngology',
          summary: 'Documents association between mouth breathing and facial development changes.',
        ),
      ],
      warnings: [
        'If you cannot breathe through your nose, consult an ENT specialist',
        'Do not use mouth tape without medical guidance',
        'Address underlying issues like deviated septum or allergies',
      ],
      requiresMedicalDisclaimer: true,
    ),
  ];

  /// Get exercises by category
  static List<OrthotropicExercise> getByCategory(ExerciseCategory category) {
    return allExercises.where((e) => e.category == category).toList();
  }

  /// Get exercises by evidence strength
  static List<OrthotropicExercise> getByEvidenceStrength(EvidenceStrength strength) {
    return allExercises.where((e) => e.evidenceStrength == strength).toList();
  }

  /// Get exercises appropriate for a given age
  static List<OrthotropicExercise> getForAge(int age) {
    return allExercises.where((e) {
      if (e.minAgeRecommended != null && age < e.minAgeRecommended!) {
        return false;
      }
      if (e.maxAgeRecommended != null && age > e.maxAgeRecommended!) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Get exercise by ID
  static OrthotropicExercise? getById(String id) {
    try {
      return allExercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get all exercises sorted by evidence strength (strongest first)
  static List<OrthotropicExercise> getAllSortedByEvidence() {
    final sorted = List<OrthotropicExercise>.from(allExercises);
    sorted.sort((a, b) {
      final evidenceOrder = {
        EvidenceStrength.strong: 0,
        EvidenceStrength.moderate: 1,
        EvidenceStrength.limited: 2,
        EvidenceStrength.none: 3,
      };
      return evidenceOrder[a.evidenceStrength]!
          .compareTo(evidenceOrder[b.evidenceStrength]!);
    });
    return sorted;
  }
}

/// Banned/dangerous practices that should NEVER be recommended
class BannedPractices {
  static const List<Map<String, String>> bannedList = [
    {
      'name': 'Bone Smashing',
      'description': 'Repeatedly hitting face to stimulate bone growth',
      'reason': 'Zero scientific basis. Risk of bone microfractures, nerve damage, '
          'and permanent injury. Violates basic orthopedic principles.',
      'evidenceAssessment': 'NO EVIDENCE - Pseudoscience with serious injury risk',
    },
    {
      'name': 'Face Pulling',
      'description': 'Manual force to attempt bone remodeling',
      'reason': 'No scientific basis for manual bone remodeling. Risk of nerve '
          'damage, joint issues, and TMJ disorders.',
      'evidenceAssessment': 'NO EVIDENCE - Can cause nerve and bone damage',
    },
    {
      'name': 'Subliminal Audio',
      'description': 'Audio tracks claiming to change facial structure',
      'reason': 'Not physiologically possible. Audio cannot change bone or tissue structure.',
      'evidenceAssessment': 'NO EVIDENCE - Not physiologically possible',
    },
    {
      'name': 'Extreme Caloric Restriction',
      'description': 'Severe dieting for facial fat loss',
      'reason': 'Eating disorder risk. Can cause muscle loss, hormonal issues, '
          'and actually worsen facial appearance through skin sagging.',
      'evidenceAssessment': 'HARMFUL - Eating disorder risk, no facial benefits',
    },
    {
      'name': 'Testosterone/Hormone Supplements (Without Medical Supervision)',
      'description': 'Self-administered hormones for masculinization',
      'reason': 'Dangerous for teens. Can cause permanent hormonal disruption, '
          'organ damage, and serious health issues. Requires medical supervision.',
      'evidenceAssessment': 'DANGEROUS - Requires medical supervision only',
    },
    {
      'name': 'Non-FDA Approved Devices',
      'description': 'Unregulated facial devices claiming bone changes',
      'reason': 'Safety untested. No evidence of effectiveness. Risk of injury.',
      'evidenceAssessment': 'NO EVIDENCE - Safety and efficacy unproven',
    },
  ];

  /// Check if a practice is banned
  static bool isBanned(String practiceName) {
    return bannedList.any(
      (p) => p['name']!.toLowerCase() == practiceName.toLowerCase(),
    );
  }

  /// Get warning message for a banned practice
  static String? getWarningMessage(String practiceName) {
    final practice = bannedList.cast<Map<String, String>?>().firstWhere(
          (p) => p?['name']?.toLowerCase() == practiceName.toLowerCase(),
          orElse: () => null,
        );
    if (practice == null) return null;
    return '${practice['name']} is NOT recommended.\n\n'
        'Reason: ${practice['reason']}\n\n'
        'Assessment: ${practice['evidenceAssessment']}';
  }
}
