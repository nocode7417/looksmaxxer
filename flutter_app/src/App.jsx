import { useState, useCallback, useEffect } from 'react';
import { AnimatePresence } from 'framer-motion';
import { DeviceFrame, Screen } from './components/device/DeviceFrame';
import { WelcomeScreen } from './components/onboarding/WelcomeScreen';
import { CaptureRules } from './components/onboarding/CaptureRules';
import { CameraView } from './components/capture/CameraView';
import { ReportScreen } from './components/analysis/ReportScreen';
import { Dashboard } from './components/Dashboard';
import { useStorage } from './hooks/useStorage';
import { useProgression } from './hooks/useProgression';
import { generateId } from './utils/helpers';

// App states
const SCREENS = {
  WELCOME: 'welcome',
  CAPTURE_RULES: 'capture_rules',
  CAMERA: 'camera',
  ANALYZING: 'analyzing',
  REPORT: 'report',
  DASHBOARD: 'dashboard',
  DAILY_CAPTURE: 'daily_capture',
};

function App() {
  const {
    state,
    updateState,
    resetState,
    savePhoto,
    isReady: storageReady,
    completeOnboarding,
    addTimelineEntry,
  } = useStorage();

  const progression = useProgression(state, updateState);
  
  // Determine initial screen based on state
  const [currentScreen, setCurrentScreen] = useState(() => {
    if (state.hasCompletedOnboarding) {
      return SCREENS.DASHBOARD;
    }
    return SCREENS.WELCOME;
  });

  const [capturedPhotoData, setCapturedPhotoData] = useState(null);
  const [isCapturingDaily, setIsCapturingDaily] = useState(false);

  // Handle welcome screen completion
  const handleWelcomeComplete = useCallback(() => {
    setCurrentScreen(SCREENS.CAPTURE_RULES);
  }, []);

  // Handle begin capture from rules screen
  const handleBeginCapture = useCallback(() => {
    setCurrentScreen(SCREENS.CAMERA);
  }, []);

  // Handle photo capture
  const handlePhotoCapture = useCallback(async (imageData, metadata) => {
    const photoId = generateId();
    
    // Save photo to IndexedDB
    if (storageReady) {
      await savePhoto(photoId, imageData, metadata);
    }

    if (isCapturingDaily) {
      // Daily capture flow
      const confidence = metadata?.quality?.overall / 100 || 0.7;
      await addTimelineEntry(photoId, confidence);
      setIsCapturingDaily(false);
      setCurrentScreen(SCREENS.DASHBOARD);
    } else {
      // Initial onboarding capture
      setCapturedPhotoData(imageData);
      setCurrentScreen(SCREENS.REPORT);
    }
  }, [storageReady, savePhoto, isCapturingDaily, addTimelineEntry]);

  // Handle camera cancel
  const handleCameraCancel = useCallback(() => {
    if (isCapturingDaily) {
      setIsCapturingDaily(false);
      setCurrentScreen(SCREENS.DASHBOARD);
    } else {
      setCurrentScreen(SCREENS.CAPTURE_RULES);
    }
  }, [isCapturingDaily]);

  // Handle report continue (complete onboarding)
  const handleReportContinue = useCallback(async () => {
    // Generate mock metrics for the baseline
    const { analyzePhoto } = await import('./engine/analysis');
    const result = await analyzePhoto(capturedPhotoData);
    
    await completeOnboarding(generateId(), result.metrics);
    setCapturedPhotoData(null);
    setCurrentScreen(SCREENS.DASHBOARD);
  }, [capturedPhotoData, completeOnboarding]);

  // Handle daily capture from dashboard
  const handleDailyCapture = useCallback(() => {
    setIsCapturingDaily(true);
    setCurrentScreen(SCREENS.DAILY_CAPTURE);
  }, []);

  // Handle challenge completion
  const handleCompleteChallenge = useCallback(() => {
    progression.completeTodaysChallenge();
  }, [progression]);

  // Handle app reset
  const handleResetApp = useCallback(() => {
    if (window.confirm('This will delete all your data. Are you sure?')) {
      resetState();
      setCurrentScreen(SCREENS.WELCOME);
    }
  }, [resetState]);

  // Render current screen
  const renderScreen = () => {
    switch (currentScreen) {
      case SCREENS.WELCOME:
        return (
          <Screen>
            <WelcomeScreen onComplete={handleWelcomeComplete} />
          </Screen>
        );

      case SCREENS.CAPTURE_RULES:
        return (
          <Screen>
            <CaptureRules onBeginCapture={handleBeginCapture} />
          </Screen>
        );

      case SCREENS.CAMERA:
      case SCREENS.DAILY_CAPTURE:
        return (
          <CameraView
            onCapture={handlePhotoCapture}
            onCancel={handleCameraCancel}
          />
        );

      case SCREENS.REPORT:
        return (
          <Screen>
            <ReportScreen
              photoData={capturedPhotoData}
              onContinue={handleReportContinue}
            />
          </Screen>
        );

      case SCREENS.DASHBOARD:
        return (
          <Dashboard
            state={state}
            progression={progression}
            onCapturePhoto={handleDailyCapture}
            onCompleteChallenge={handleCompleteChallenge}
            onResetApp={handleResetApp}
          />
        );

      default:
        return null;
    }
  };

  return (
    <DeviceFrame>
      <AnimatePresence mode="wait">
        {renderScreen()}
      </AnimatePresence>
    </DeviceFrame>
  );
}

export default App;
