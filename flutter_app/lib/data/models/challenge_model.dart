/// Challenge categories
enum ChallengeCategory {
  hydration,
  sleep,
  posture,
  skincare,
  nutrition,
}

extension ChallengeCategoryExtension on ChallengeCategory {
  String get displayName {
    switch (this) {
      case ChallengeCategory.hydration:
        return 'Hydration';
      case ChallengeCategory.sleep:
        return 'Sleep';
      case ChallengeCategory.posture:
        return 'Posture';
      case ChallengeCategory.skincare:
        return 'Skincare';
      case ChallengeCategory.nutrition:
        return 'Nutrition';
    }
  }

  String get emoji {
    switch (this) {
      case ChallengeCategory.hydration:
        return '\u{1F4A7}'; // Water drop
      case ChallengeCategory.sleep:
        return '\u{1F634}'; // Sleeping face
      case ChallengeCategory.posture:
        return '\u{1F9CD}'; // Standing person
      case ChallengeCategory.skincare:
        return '\u{2728}'; // Sparkles
      case ChallengeCategory.nutrition:
        return '\u{1F34E}'; // Apple
    }
  }
}

/// Challenge model
class Challenge {
  final String id;
  final ChallengeCategory category;
  final String title;
  final String description;
  final String? tip;

  const Challenge({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    this.tip,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category.name,
      'title': title,
      'description': description,
      'tip': tip,
    };
  }

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'],
      category: ChallengeCategory.values.firstWhere(
        (c) => c.name == map['category'],
      ),
      title: map['title'],
      description: map['description'],
      tip: map['tip'],
    );
  }
}

/// All available challenges
class ChallengeRepository {
  static const List<Challenge> allChallenges = [
    // Hydration challenges
    Challenge(
      id: 'hydration_3l',
      category: ChallengeCategory.hydration,
      title: 'Drink 3L of water',
      description: 'Track your water intake throughout the day',
      tip: 'Keep a water bottle with you at all times',
    ),
    Challenge(
      id: 'hydration_morning',
      category: ChallengeCategory.hydration,
      title: 'Morning hydration',
      description: 'Drink a glass of water within 30 minutes of waking',
      tip: 'Keep water by your bedside',
    ),
    Challenge(
      id: 'hydration_sodium',
      category: ChallengeCategory.hydration,
      title: 'Monitor sodium',
      description: 'Be mindful of sodium intake today',
      tip: 'Check nutrition labels on packaged foods',
    ),

    // Sleep challenges
    Challenge(
      id: 'sleep_7hours',
      category: ChallengeCategory.sleep,
      title: 'Get 7+ hours of sleep',
      description: 'Aim for at least 7 hours of quality sleep',
      tip: 'Set a bedtime alarm 8 hours before wake time',
    ),
    Challenge(
      id: 'sleep_consistency',
      category: ChallengeCategory.sleep,
      title: 'Sleep consistency',
      description: 'Go to bed within 30 minutes of your usual time',
      tip: 'Consistent sleep times improve sleep quality',
    ),
    Challenge(
      id: 'sleep_environment',
      category: ChallengeCategory.sleep,
      title: 'Optimize sleep environment',
      description: 'Ensure your room is dark, cool, and quiet',
      tip: 'Consider blackout curtains or an eye mask',
    ),

    // Posture challenges
    Challenge(
      id: 'posture_mewing',
      category: ChallengeCategory.posture,
      title: 'Practice mewing',
      description: 'Maintain proper tongue posture throughout the day',
      tip: 'Tongue on roof of mouth, teeth lightly together',
    ),
    Challenge(
      id: 'posture_neck',
      category: ChallengeCategory.posture,
      title: 'Neck alignment check',
      description: 'Check and correct forward head posture hourly',
      tip: 'Ears should align with shoulders when standing',
    ),
    Challenge(
      id: 'posture_hourly',
      category: ChallengeCategory.posture,
      title: 'Hourly posture checks',
      description: 'Set reminders to check posture every hour',
      tip: 'Use phone reminders or posture apps',
    ),

    // Skincare challenges
    Challenge(
      id: 'skincare_ampm',
      category: ChallengeCategory.skincare,
      title: 'Complete AM/PM routine',
      description: 'Follow your full skincare routine morning and night',
      tip: 'Consistency is key for visible results',
    ),
    Challenge(
      id: 'skincare_spf',
      category: ChallengeCategory.skincare,
      title: 'Apply SPF',
      description: 'Apply sunscreen before going outside',
      tip: 'SPF 30+ recommended for daily use',
    ),
    Challenge(
      id: 'skincare_gentle',
      category: ChallengeCategory.skincare,
      title: 'Gentle cleansing',
      description: 'Use a gentle cleanser, avoid harsh scrubbing',
      tip: 'Pat dry instead of rubbing',
    ),

    // Nutrition challenges
    Challenge(
      id: 'nutrition_protein',
      category: ChallengeCategory.nutrition,
      title: 'Hit protein goal',
      description: 'Consume adequate protein for your body weight',
      tip: 'Aim for 0.8-1g per pound of body weight',
    ),
    Challenge(
      id: 'nutrition_sugar',
      category: ChallengeCategory.nutrition,
      title: 'Reduce sugar intake',
      description: 'Limit added sugars today',
      tip: 'Check labels for hidden sugars',
    ),
    Challenge(
      id: 'nutrition_antiinflammatory',
      category: ChallengeCategory.nutrition,
      title: 'Anti-inflammatory foods',
      description: 'Include anti-inflammatory foods in your diet',
      tip: 'Try fatty fish, berries, leafy greens',
    ),
  ];

  /// Get challenges by category
  static List<Challenge> getByCategory(ChallengeCategory category) {
    return allChallenges.where((c) => c.category == category).toList();
  }

  /// Get a pseudo-random challenge for the day
  static Challenge getDailyChallenge(DateTime date) {
    // Use date as seed for consistent daily challenge
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final index = seed % allChallenges.length;
    return allChallenges[index];
  }

  /// Get challenge by ID
  static Challenge? getById(String id) {
    try {
      return allChallenges.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
