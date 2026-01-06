import { useState, useEffect, useCallback, useMemo } from 'react';
import { calculateProgressScore, checkUnlockStatus, getScoreMessage } from '../game/scoring';
import { getTodaysChallenge, getStreakInfo, isChallengeCompletedToday } from '../game/challenges';
import { daysUntilConfidentProgress } from '../engine/confidence';

export function useProgression(state, updateState) {
  const [todaysChallenge, setTodaysChallenge] = useState(null);

  // Get today's challenge
  useEffect(() => {
    const challenge = getTodaysChallenge();
    setTodaysChallenge(challenge);
  }, []);

  // Calculate progress score
  const progressInfo = useMemo(() => {
    return calculateProgressScore(state);
  }, [state]);

  // Get unlock status
  const unlockStatus = useMemo(() => {
    return checkUnlockStatus(state);
  }, [state]);

  // Get streak info
  const streakInfo = useMemo(() => {
    return getStreakInfo(
      state.challenges,
      state.lastChallengeDate,
      state.challengeStreak
    );
  }, [state.challenges, state.lastChallengeDate, state.challengeStreak]);

  // Check if today's challenge is completed
  const isTodayCompleted = useMemo(() => {
    if (!todaysChallenge) return false;
    return isChallengeCompletedToday(state.challenges, todaysChallenge.id);
  }, [state.challenges, todaysChallenge]);

  // Days until confident progress
  const confidenceProgress = useMemo(() => {
    if (!state.createdAt) return null;
    return daysUntilConfidentProgress(
      state.createdAt,
      14,
      7,
      state.timeline.length
    );
  }, [state.createdAt, state.timeline.length]);

  // Get score message
  const scoreMessage = useMemo(() => {
    return getScoreMessage(progressInfo.score, progressInfo.trend);
  }, [progressInfo]);

  // Complete today's challenge
  const completeTodaysChallenge = useCallback(() => {
    if (!todaysChallenge || isTodayCompleted) return;

    const today = new Date().toISOString().split('T')[0];
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    const isStreakContinued = state.lastChallengeDate === yesterday;

    const challenge = {
      id: `${todaysChallenge.id}-${today}`,
      challengeId: todaysChallenge.id,
      date: today,
      completedAt: new Date().toISOString(),
    };

    updateState({
      challenges: [...state.challenges, challenge],
      challengeStreak: isStreakContinued ? state.challengeStreak + 1 : 1,
      lastChallengeDate: today,
    });
  }, [todaysChallenge, isTodayCompleted, state, updateState]);

  // Get timeline stats
  const timelineStats = useMemo(() => {
    const { timeline } = state;
    if (timeline.length === 0) {
      return {
        totalPhotos: 0,
        avgConfidence: 0,
        firstDate: null,
        lastDate: null,
        daysCovered: 0,
      };
    }

    const confidences = timeline.map(t => t.confidence || 0.5);
    const avgConfidence = confidences.reduce((a, b) => a + b, 0) / confidences.length;

    const dates = timeline.map(t => new Date(t.date).getTime());
    const firstDate = new Date(Math.min(...dates));
    const lastDate = new Date(Math.max(...dates));
    const daysCovered = Math.ceil((lastDate - firstDate) / (1000 * 60 * 60 * 24)) + 1;

    return {
      totalPhotos: timeline.length,
      avgConfidence: Math.round(avgConfidence * 100),
      firstDate,
      lastDate,
      daysCovered,
    };
  }, [state.timeline]);

  return {
    // Progress
    progressInfo,
    unlockStatus,
    scoreMessage,
    confidenceProgress,

    // Challenges
    todaysChallenge,
    isTodayCompleted,
    completeTodaysChallenge,
    streakInfo,

    // Timeline
    timelineStats,

    // Helper values
    isProgressLocked: progressInfo.isLocked,
    progressScore: progressInfo.score,
    daysRemaining: unlockStatus.remaining?.days ?? 14,
  };
}

export default useProgression;

