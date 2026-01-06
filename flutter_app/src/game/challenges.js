// Daily micro-challenges system
// Framed as experiments, not tasks

export const CHALLENGE_CATEGORIES = {
  hydration: {
    id: 'hydration',
    name: 'Hydration',
    icon: 'Droplets',
    color: '#3b82f6',
    description: 'Cellular hydration affects skin texture and fullness',
  },
  sleep: {
    id: 'sleep',
    name: 'Sleep',
    icon: 'Moon',
    color: '#8b5cf6',
    description: 'Recovery cycles impact inflammation and tissue repair',
  },
  posture: {
    id: 'posture',
    name: 'Posture',
    icon: 'Activity',
    color: '#10b981',
    description: 'Structural alignment affects jaw position and neck tension',
  },
  skincare: {
    id: 'skincare',
    name: 'Skincare',
    icon: 'Sparkles',
    color: '#f59e0b',
    description: 'Consistent routine improves texture measurement accuracy',
  },
  nutrition: {
    id: 'nutrition',
    name: 'Nutrition',
    icon: 'Heart',
    color: '#ef4444',
    description: 'Micronutrients influence inflammation markers',
  },
};

export const CHALLENGES = [
  // Hydration challenges
  {
    id: 'hydration-3l',
    category: 'hydration',
    title: 'Hydration experiment',
    description: 'Track 3L water intake over 24 hours',
    rationale: 'Acute hydration changes are detectable in skin texture variance within 24-48 hours',
    difficulty: 'easy',
    duration: '24h',
  },
  {
    id: 'hydration-morning',
    category: 'hydration',
    title: 'Morning hydration',
    description: '500ml water within 30 minutes of waking',
    rationale: 'Rehydration after sleep affects morning facial volume measurements',
    difficulty: 'easy',
    duration: '30min',
  },
  {
    id: 'hydration-sodium',
    category: 'hydration',
    title: 'Sodium observation',
    description: 'Note sodium intake and observe facial puffiness',
    rationale: 'Sodium-water balance affects soft tissue measurements',
    difficulty: 'medium',
    duration: '24h',
  },
  
  // Sleep challenges
  {
    id: 'sleep-7h',
    category: 'sleep',
    title: 'Sleep duration',
    description: '7+ hours of sleep tonight',
    rationale: 'Sleep debt accumulation visibly affects periorbital area and skin recovery',
    difficulty: 'easy',
    duration: 'overnight',
  },
  {
    id: 'sleep-consistency',
    category: 'sleep',
    title: 'Sleep schedule',
    description: 'Same bedtime ±30 minutes for 3 consecutive nights',
    rationale: 'Circadian consistency improves baseline measurement stability',
    difficulty: 'medium',
    duration: '3 days',
  },
  {
    id: 'sleep-quality',
    category: 'sleep',
    title: 'Sleep environment',
    description: 'Dark room, no screens 1 hour before bed',
    rationale: 'Sleep quality affects recovery hormone release and tissue repair',
    difficulty: 'medium',
    duration: 'overnight',
  },
  
  // Posture challenges
  {
    id: 'posture-mewing',
    category: 'posture',
    title: 'Tongue posture check',
    description: 'Maintain proper tongue position (mewing) for 4 hours',
    rationale: 'Consistent oral posture may influence jaw muscle tension over time',
    difficulty: 'medium',
    duration: '4h',
  },
  {
    id: 'posture-neck',
    category: 'posture',
    title: 'Neck alignment',
    description: 'Avoid forward head posture while working',
    rationale: 'Chronic forward posture affects submental angle and jaw definition',
    difficulty: 'medium',
    duration: 'workday',
  },
  {
    id: 'posture-check',
    category: 'posture',
    title: 'Posture audit',
    description: 'Set 4 hourly reminders to check head position',
    rationale: 'Awareness is the first step to postural adaptation',
    difficulty: 'easy',
    duration: '8h',
  },
  
  // Skincare challenges
  {
    id: 'skincare-routine',
    category: 'skincare',
    title: 'AM + PM routine',
    description: 'Complete moisturizing routine morning and evening',
    rationale: 'Consistent hydration improves texture measurement reliability',
    difficulty: 'easy',
    duration: '24h',
  },
  {
    id: 'skincare-spf',
    category: 'skincare',
    title: 'Sun protection',
    description: 'Apply SPF before any outdoor exposure',
    rationale: 'UV damage creates cumulative pigmentation variance',
    difficulty: 'easy',
    duration: 'daily',
  },
  {
    id: 'skincare-gentle',
    category: 'skincare',
    title: 'Gentle cleansing',
    description: 'Use gentle cleanser only, no harsh exfoliation',
    rationale: 'Barrier integrity affects redness and texture readings',
    difficulty: 'easy',
    duration: '24h',
  },
  
  // Nutrition challenges
  {
    id: 'nutrition-protein',
    category: 'nutrition',
    title: 'Protein tracking',
    description: 'Aim for 1.6g/kg bodyweight protein intake',
    rationale: 'Protein supports tissue maintenance and collagen synthesis',
    difficulty: 'medium',
    duration: '24h',
  },
  {
    id: 'nutrition-sugar',
    category: 'nutrition',
    title: 'Sugar reduction',
    description: 'Minimize added sugar intake today',
    rationale: 'Glycation affects skin elasticity measurements over time',
    difficulty: 'medium',
    duration: '24h',
  },
  {
    id: 'nutrition-anti-inflammatory',
    category: 'nutrition',
    title: 'Anti-inflammatory focus',
    description: 'Include omega-3 rich foods or supplement',
    rationale: 'Systemic inflammation affects redness and puffiness markers',
    difficulty: 'easy',
    duration: '24h',
  },
];

// Get today's challenge (deterministic based on date)
export function getTodaysChallenge(dateString = new Date().toISOString().split('T')[0]) {
  // Create a simple hash from the date
  const hash = dateString.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
  const index = hash % CHALLENGES.length;
  
  return {
    ...CHALLENGES[index],
    date: dateString,
    category: CHALLENGE_CATEGORIES[CHALLENGES[index].category],
  };
}

// Get challenge by ID
export function getChallengeById(id) {
  const challenge = CHALLENGES.find(c => c.id === id);
  if (!challenge) return null;
  
  return {
    ...challenge,
    category: CHALLENGE_CATEGORIES[challenge.category],
  };
}

// Get all challenges in a category
export function getChallengesByCategory(categoryId) {
  return CHALLENGES
    .filter(c => c.category === categoryId)
    .map(c => ({
      ...c,
      category: CHALLENGE_CATEGORIES[c.category],
    }));
}

// Check if challenge was completed today
export function isChallengeCompletedToday(challenges, challengeId) {
  const today = new Date().toISOString().split('T')[0];
  return challenges.some(c => c.challengeId === challengeId && c.date === today);
}

// Get streak info
export function getStreakInfo(challenges, lastChallengeDate, currentStreak) {
  const today = new Date().toISOString().split('T')[0];
  const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
  
  const isActiveToday = challenges.some(c => c.date === today);
  const wasActiveYesterday = lastChallengeDate === yesterday;
  
  return {
    current: currentStreak,
    isActiveToday,
    wasActiveYesterday,
    willBreakTomorrow: isActiveToday && !wasActiveYesterday,
    message: isActiveToday 
      ? `${currentStreak} day streak` 
      : wasActiveYesterday 
        ? 'Complete today to continue streak'
        : 'Start a new streak today',
  };
}

export default {
  CHALLENGE_CATEGORIES,
  CHALLENGES,
  getTodaysChallenge,
  getChallengeById,
  getChallengesByCategory,
  isChallengeCompletedToday,
  getStreakInfo,
};

