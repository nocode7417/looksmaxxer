import { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Camera, RotateCcw, X, Check, AlertCircle } from 'lucide-react';
import { Button } from '../ui/Button';
import { useCamera } from '../../hooks/useCamera';
import { QualityValidator } from './QualityValidator';
import { fadeUp } from '../../utils/animations';

export function CameraView({ onCapture, onCancel }) {
  const {
    videoRef,
    isReady,
    error,
    facingMode,
    startCamera,
    stopCamera,
    toggleCamera,
    capturePhoto,
    analyzeQuality,
  } = useCamera();

  const [capturedPhoto, setCapturedPhoto] = useState(null);
  const [quality, setQuality] = useState(null);
  const [isAnalyzing, setIsAnalyzing] = useState(false);

  // Start camera on mount
  useEffect(() => {
    startCamera();
    return () => stopCamera();
  }, []);

  // Handle capture
  const handleCapture = useCallback(async () => {
    const photo = capturePhoto();
    if (!photo) return;

    setCapturedPhoto(photo);
    setIsAnalyzing(true);

    // Analyze quality
    const qualityResult = await analyzeQuality(photo.imageData);
    setQuality(qualityResult);
    setIsAnalyzing(false);
  }, [capturePhoto, analyzeQuality]);

  // Handle retake
  const handleRetake = useCallback(() => {
    setCapturedPhoto(null);
    setQuality(null);
  }, []);

  // Handle accept
  const handleAccept = useCallback(() => {
    if (capturedPhoto && quality) {
      onCapture?.(capturedPhoto.imageData, {
        ...capturedPhoto.metadata,
        quality,
      });
    }
  }, [capturedPhoto, quality, onCapture]);

  // Error state
  if (error) {
    return (
      <div className="min-h-full flex flex-col items-center justify-center bg-[var(--color-background)] px-6">
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          className="text-center"
        >
          <div className="w-16 h-16 rounded-full bg-[var(--color-surface-elevated)] flex items-center justify-center mx-auto mb-4">
            <AlertCircle size={32} strokeWidth={1.5} className="text-[var(--color-error)]" />
          </div>
          <h2 className="text-[17px] font-semibold text-[var(--color-text-primary)] mb-2">
            Camera Access Required
          </h2>
          <p className="text-[15px] text-[var(--color-text-secondary)] mb-6 max-w-[280px]">
            {error}
          </p>
          <Button onClick={startCamera}>
            Try Again
          </Button>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-full flex flex-col bg-black">
      {/* Camera preview or captured photo */}
      <div className="flex-1 relative overflow-hidden">
        <AnimatePresence mode="wait">
          {capturedPhoto ? (
            <motion.div
              key="preview"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute inset-0"
            >
              <img
                src={capturedPhoto.imageData}
                alt="Captured"
                className="w-full h-full object-cover"
              />
            </motion.div>
          ) : (
            <motion.div
              key="camera"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="absolute inset-0"
            >
              <video
                ref={videoRef}
                autoPlay
                playsInline
                muted
                className="w-full h-full object-cover"
                style={{ transform: facingMode === 'user' ? 'scaleX(-1)' : 'none' }}
              />

              {/* Alignment guide */}
              <div className="absolute inset-0 pointer-events-none">
                <AlignmentGuide />
              </div>
            </motion.div>
          )}
        </AnimatePresence>

        {/* Top bar */}
        <div className="absolute top-0 left-0 right-0 pt-4 px-4 z-10">
          <div className="flex justify-between items-center">
            <button
              onClick={onCancel}
              className="w-10 h-10 rounded-full bg-black/40 backdrop-blur-sm flex items-center justify-center"
            >
              <X size={20} strokeWidth={2} className="text-white" />
            </button>
            
            {!capturedPhoto && (
              <button
                onClick={toggleCamera}
                className="w-10 h-10 rounded-full bg-black/40 backdrop-blur-sm flex items-center justify-center"
              >
                <RotateCcw size={20} strokeWidth={2} className="text-white" />
              </button>
            )}
          </div>
        </div>

        {/* Quality indicator */}
        {capturedPhoto && (
          <div className="absolute bottom-0 left-0 right-0 p-4 z-10">
            <QualityValidator quality={quality} isAnalyzing={isAnalyzing} />
          </div>
        )}
      </div>

      {/* Bottom controls */}
      <div className="bg-[var(--color-background)] px-6 py-6">
        <AnimatePresence mode="wait">
          {capturedPhoto ? (
            <motion.div
              key="review"
              {...fadeUp}
              className="flex gap-4"
            >
              <Button
                variant="secondary"
                size="lg"
                className="flex-1"
                onClick={handleRetake}
                icon={RotateCcw}
              >
                Retake
              </Button>
              <Button
                size="lg"
                className="flex-1"
                onClick={handleAccept}
                disabled={isAnalyzing || (quality && !quality.isAcceptable)}
                icon={Check}
              >
                {isAnalyzing ? 'Analyzing...' : 'Use Photo'}
              </Button>
            </motion.div>
          ) : (
            <motion.div
              key="capture"
              {...fadeUp}
              className="flex justify-center"
            >
              <CaptureButton onCapture={handleCapture} isReady={isReady} />
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}

// Capture button component
function CaptureButton({ onCapture, isReady }) {
  return (
    <motion.button
      whileTap={{ scale: 0.95 }}
      onClick={onCapture}
      disabled={!isReady}
      className="w-[72px] h-[72px] rounded-full bg-white flex items-center justify-center disabled:opacity-50"
    >
      <div className="w-[62px] h-[62px] rounded-full border-[3px] border-[var(--color-background)] flex items-center justify-center">
        <Camera size={28} strokeWidth={1.5} className="text-[var(--color-background)]" />
      </div>
    </motion.button>
  );
}

// Alignment guide overlay
function AlignmentGuide() {
  return (
    <div className="absolute inset-0 flex items-center justify-center">
      {/* Face oval guide */}
      <svg
        viewBox="0 0 200 280"
        className="w-[55%] h-auto opacity-40"
      >
        <ellipse
          cx="100"
          cy="140"
          rx="85"
          ry="120"
          fill="none"
          stroke="white"
          strokeWidth="1.5"
          strokeDasharray="8 4"
        />
        {/* Center crosshair */}
        <line x1="95" y1="140" x2="105" y2="140" stroke="white" strokeWidth="1" />
        <line x1="100" y1="135" x2="100" y2="145" stroke="white" strokeWidth="1" />
        {/* Eye level line */}
        <line x1="40" y1="110" x2="60" y2="110" stroke="white" strokeWidth="0.75" opacity="0.6" />
        <line x1="140" y1="110" x2="160" y2="110" stroke="white" strokeWidth="0.75" opacity="0.6" />
      </svg>

      {/* Instructions */}
      <div className="absolute bottom-32 left-0 right-0 text-center">
        <p className="text-[13px] text-white/70 font-medium">
          Align your face within the guide
        </p>
      </div>
    </div>
  );
}

export default CameraView;

