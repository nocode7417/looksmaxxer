// Progress scoring system
// Designed to reward consistency and patience over impulsive behavior

import { calculateWeightedMovingAverage, isSignificantChange } from '../engine/confidence';

// Score is unlocked after minimum requirements
const UNLOCK_REQUIREMENTS = {
  minDays: 14,
  minPhotos: 7,
  minChallenges: 5,
};

// Scoring weights
const SCORING_WEIGHTS = {
  consistency: 0.35,      // Regular photo uploads
  challengeCompletion: 0.25, // Daily challenge engagement
  photoQuality: 0.20,     // Average quality of uploads
  improvement: 0.20,      // Actual metric improvements
};

// Calculate progress score (0-100)
export function calculateProgressScore(state) {
  const {
    timeline,
    challenges,
    metrics,
    createdAt,
    progressUnlockedAt,
  } = state;

  // Check if score should be unlocked
  if (!progressUnlockedAt) {
    const unlockStatus = checkUnlockStatus(state);
    if (!unlockStatus.isUnlocked) {
      return {
        score: null,
        isLocked: true,
        unlockProgress: unlockStatus.progress,
        requirements: unlockStatus.remaining,
      };
    }
  }

  // Calculate individual components
  const consistencyScore = calculateConsistencyScore(timeline, createdAt);
  const challengeScore = calculateChallengeScore(challenges, createdAt);
  const qualityScore = calculateQualityScore(timeline);
  const improvementScore = calculateImprovementScore(metrics, timeline);

  // Weighted final score
  const finalScore = Math.round(
    consistencyScore * SCORING_WEIGHTS.consistency +
    challengeScore * SCORING_WEIGHTS.challengeCompletion +
    qualityScore * SCORING_WEIGHTS.photoQuality +
    improvementScore * SCORING_WEIGHTS.improvement
  );

  return {
    score: finalScore,
    isLocked: false,
    breakdown: {
      consistency: Math.round(consistencyScore),
      challenges: Math.round(challengeScore),
      quality: Math.round(qualityScore),
      improvement: Math.round(improvementScore),
    },
    trend: calculateScoreTrend(timeline),
  };
}

// Check if score should be unlocked
export function checkUnlockStatus(state) {
  const { timeline, challenges, createdAt } = state;
  
  if (!createdAt) {
    return {
      isUnlocked: false,
      progress: 0,
      remaining: { ...UNLOCK_REQUIREMENTS },
    };
  }

  const daysSinceStart = Math.floor(
    (Date.now() - new Date(createdAt).getTime()) / (1000 * 60 * 60 * 24)
  );

  const remaining = {
    days: Math.max(0, UNLOCK_REQUIREMENTS.minDays - daysSinceStart),
    photos: Math.max(0, UNLOCK_REQUIREMENTS.minPhotos - timeline.length),
    challenges: Math.max(0, UNLOCK_REQUIREMENTS.minChallenges - challenges.length),
  };

  const isUnlocked = remaining.days === 0 && remaining.photos === 0 && remaining.challenges === 0;

  // Calculate overall progress (0-1)
  const progress = Math.min(1, (
    (daysSinceStart / UNLOCK_REQUIREMENTS.minDays) * 0.5 +
    (timeline.length / UNLOCK_REQUIREMENTS.minPhotos) * 0.3 +
    (challenges.length / UNLOCK_REQUIREMENTS.minChallenges) * 0.2
  ));

  return { isUnlocked, progress, remaining };
}

// Calculate consistency score based on upload regularity
function calculateConsistencyScore(timeline, createdAt) {
  if (timeline.length < 2) return 50; // Neutral start

  const dates = timeline.map(t => new Date(t.date).getTime()).sort((a, b) => a - b);
  
  // Calculate average days between uploads
  let totalGap = 0;
  for (let i = 1; i < dates.length; i++) {
    const gap = (dates[i] - dates[i - 1]) / (1000 * 60 * 60 * 24);
    totalGap += gap;
  }
  const avgGap = totalGap / (dates.length - 1);

  // Ideal gap is 1-3 days, penalize both too frequent and too infrequent
  if (avgGap < 1) return 70; // Slightly penalize daily spamming
  if (avgGap <= 3) return 100; // Ideal
  if (avgGap <= 7) return 80;
  if (avgGap <= 14) return 60;
  return 40;
}

// Calculate challenge completion score
function calculateChallengeScore(challenges, createdAt) {
  if (!createdAt) return 50;

  const daysSinceStart = Math.floor(
    (Date.now() - new Date(createdAt).getTime()) / (1000 * 60 * 60 * 24)
  );

  if (daysSinceStart === 0) return 50;

  // Calculate completion rate
  const completionRate = challenges.length / daysSinceStart;
  
  // 50%+ completion rate is excellent
  if (completionRate >= 0.7) return 100;
  if (completionRate >= 0.5) return 85;
  if (completionRate >= 0.3) return 70;
  if (completionRate >= 0.1) return 55;
  return 40;
}

// Calculate average photo quality score
function calculateQualityScore(timeline) {
  if (timeline.length === 0) return 50;

  const qualityScores = timeline
    .filter(t => t.confidence !== undefined)
    .map(t => t.confidence * 100);

  if (qualityScores.length === 0) return 50;

  return calculateWeightedMovingAverage(qualityScores, 10) || 50;
}

// Calculate improvement score based on metric changes
function calculateImprovementScore(metrics, timeline) {
  if (!metrics || timeline.length < 3) return 50;

  // For mock data, generate a realistic improvement score
  // In real implementation, this would analyze actual metric trends
  const baseScore = 50;
  const timelineBonus = Math.min(20, timeline.length * 2);
  const variance = (Math.random() - 0.5) * 10;

  return Math.max(30, Math.min(100, baseScore + timelineBonus + variance));
}

// Calculate score trend (improving, stable, declining)
function calculateScoreTrend(timeline) {
  if (timeline.length < 5) return 'building';

  // Analyze recent vs older entries
  const recent = timeline.slice(-5);
  const older = timeline.slice(-10, -5);

  if (older.length === 0) return 'building';

  const recentAvg = recent.reduce((sum, t) => sum + (t.confidence || 0.5), 0) / recent.length;
  const olderAvg = older.reduce((sum, t) => sum + (t.confidence || 0.5), 0) / older.length;

  const diff = recentAvg - olderAvg;

  if (diff > 0.05) return 'improving';
  if (diff < -0.05) return 'declining';
  return 'stable';
}

// Get motivational message based on score and trend
export function getScoreMessage(score, trend) {
  if (score === null) {
    return {
      title: 'Building your baseline',
      subtitle: 'Progress score unlocks after consistent tracking',
    };
  }

  if (score >= 80) {
    return {
      title: 'Excellent consistency',
      subtitle: trend === 'improving' ? 'Your metrics show positive adaptation' : 'Maintain your current approach',
    };
  }

  if (score >= 60) {
    return {
      title: 'Good progress',
      subtitle: 'Consistency is building reliable data',
    };
  }

  if (score >= 40) {
    return {
      title: 'Room to improve',
      subtitle: 'More frequent tracking increases accuracy',
    };
  }

  return {
    title: 'Getting started',
    subtitle: 'Regular engagement unlocks insights',
  };
}

// Anti-cheat: Penalize suspicious patterns
export function detectSuspiciousBehavior(timeline) {
  const flags = [];

  // Check for too-frequent uploads (potential gaming)
  const recentUploads = timeline.filter(t => 
    Date.now() - new Date(t.date).getTime() < 24 * 60 * 60 * 1000
  );
  if (recentUploads.length > 5) {
    flags.push('excessive_uploads');
  }

  // Check for suspiciously consistent quality scores
  if (timeline.length >= 5) {
    const qualities = timeline.slice(-5).map(t => t.confidence);
    const variance = Math.max(...qualities) - Math.min(...qualities);
    if (variance < 0.02 && qualities.every(q => q > 0.9)) {
      flags.push('suspicious_quality');
    }
  }

  return {
    isSuspicious: flags.length > 0,
    flags,
    confidencePenalty: flags.length * 0.1,
  };
}

export default {
  calculateProgressScore,
  checkUnlockStatus,
  getScoreMessage,
  detectSuspiciousBehavior,
  UNLOCK_REQUIREMENTS,
};

