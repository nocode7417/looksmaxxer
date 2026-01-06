import { useState, useEffect, useCallback } from 'react';
import { openDB } from 'idb';

const DB_NAME = 'looksmaxxer-db';
const DB_VERSION = 1;
const PHOTOS_STORE = 'photos';
const STORAGE_KEY = 'looksmaxxer-data';

// Initialize IndexedDB for photo storage
async function initDB() {
  return openDB(DB_NAME, DB_VERSION, {
    upgrade(db) {
      if (!db.objectStoreNames.contains(PHOTOS_STORE)) {
        db.createObjectStore(PHOTOS_STORE, { keyPath: 'id' });
      }
    },
  });
}

// Default app state
const defaultState = {
  hasCompletedOnboarding: false,
  baselinePhotoId: null,
  baselineDate: null,
  metrics: null,
  timeline: [],
  challenges: [],
  challengeStreak: 0,
  lastChallengeDate: null,
  progressScore: null,
  progressUnlockedAt: null,
  settings: {
    notifications: true,
    haptics: true,
  },
  createdAt: null,
};

// LocalStorage hook for app state
export function useAppState() {
  const [state, setState] = useState(() => {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) {
        return { ...defaultState, ...JSON.parse(stored) };
      }
    } catch (e) {
      console.error('Failed to load state:', e);
    }
    return defaultState;
  });

  // Persist state changes
  useEffect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
    } catch (e) {
      console.error('Failed to save state:', e);
    }
  }, [state]);

  const updateState = useCallback((updates) => {
    setState(prev => ({ ...prev, ...updates }));
  }, []);

  const resetState = useCallback(() => {
    localStorage.removeItem(STORAGE_KEY);
    setState(defaultState);
  }, []);

  return { state, updateState, resetState };
}

// IndexedDB hook for photos
export function usePhotoDB() {
  const [db, setDb] = useState(null);

  useEffect(() => {
    initDB().then(setDb).catch(console.error);
  }, []);

  const savePhoto = useCallback(async (id, imageData, metadata = {}) => {
    if (!db) throw new Error('Database not initialized');
    
    const photo = {
      id,
      imageData,
      metadata,
      createdAt: new Date().toISOString(),
    };
    
    await db.put(PHOTOS_STORE, photo);
    return photo;
  }, [db]);

  const getPhoto = useCallback(async (id) => {
    if (!db) return null;
    return db.get(PHOTOS_STORE, id);
  }, [db]);

  const getAllPhotos = useCallback(async () => {
    if (!db) return [];
    return db.getAll(PHOTOS_STORE);
  }, [db]);

  const deletePhoto = useCallback(async (id) => {
    if (!db) return;
    await db.delete(PHOTOS_STORE, id);
  }, [db]);

  return { savePhoto, getPhoto, getAllPhotos, deletePhoto, isReady: !!db };
}

// Combined storage hook
export function useStorage() {
  const { state, updateState, resetState } = useAppState();
  const photoDB = usePhotoDB();

  // Complete onboarding with baseline photo
  const completeOnboarding = useCallback(async (photoId, metrics) => {
    updateState({
      hasCompletedOnboarding: true,
      baselinePhotoId: photoId,
      baselineDate: new Date().toISOString(),
      metrics,
      createdAt: new Date().toISOString(),
    });
  }, [updateState]);

  // Add photo to timeline
  const addTimelineEntry = useCallback(async (photoId, confidence) => {
    const entry = {
      id: photoId,
      date: new Date().toISOString(),
      confidence,
      processed: false,
    };
    
    updateState({
      timeline: [...state.timeline, entry],
    });
    
    return entry;
  }, [state.timeline, updateState]);

  // Update metrics
  const updateMetrics = useCallback((newMetrics) => {
    updateState({
      metrics: {
        ...state.metrics,
        ...newMetrics,
        lastUpdated: new Date().toISOString(),
      },
    });
  }, [state.metrics, updateState]);

  // Record challenge completion
  const completeChallenge = useCallback((challengeId) => {
    const today = new Date().toISOString().split('T')[0];
    const isStreakContinued = state.lastChallengeDate === 
      new Date(Date.now() - 86400000).toISOString().split('T')[0];
    
    const challenge = {
      id: `${challengeId}-${today}`,
      challengeId,
      date: today,
      completedAt: new Date().toISOString(),
    };
    
    updateState({
      challenges: [...state.challenges, challenge],
      challengeStreak: isStreakContinued ? state.challengeStreak + 1 : 1,
      lastChallengeDate: today,
    });
    
    return challenge;
  }, [state.challenges, state.challengeStreak, state.lastChallengeDate, updateState]);

  // Check if progress score should be unlocked (14+ days)
  const checkProgressUnlock = useCallback(() => {
    if (state.progressUnlockedAt) return true;
    
    if (state.createdAt) {
      const daysSinceStart = Math.floor(
        (Date.now() - new Date(state.createdAt).getTime()) / (1000 * 60 * 60 * 24)
      );
      
      if (daysSinceStart >= 14 && state.timeline.length >= 7) {
        updateState({
          progressUnlockedAt: new Date().toISOString(),
          progressScore: 0,
        });
        return true;
      }
    }
    
    return false;
  }, [state.createdAt, state.progressUnlockedAt, state.timeline.length, updateState]);

  return {
    state,
    updateState,
    resetState,
    ...photoDB,
    completeOnboarding,
    addTimelineEntry,
    updateMetrics,
    completeChallenge,
    checkProgressUnlock,
  };
}

export default useStorage;

