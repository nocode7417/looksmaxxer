import { useState, useRef, useCallback, useEffect } from 'react';

export function useCamera() {
  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const streamRef = useRef(null);
  
  const [isReady, setIsReady] = useState(false);
  const [error, setError] = useState(null);
  const [facingMode, setFacingMode] = useState('user'); // 'user' = front, 'environment' = back

  // Initialize camera
  const startCamera = useCallback(async () => {
    try {
      setError(null);
      
      // Stop any existing stream
      if (streamRef.current) {
        streamRef.current.getTracks().forEach(track => track.stop());
      }

      const constraints = {
        video: {
          facingMode,
          width: { ideal: 1080 },
          height: { ideal: 1920 },
          aspectRatio: { ideal: 9 / 16 },
        },
        audio: false,
      };

      const stream = await navigator.mediaDevices.getUserMedia(constraints);
      streamRef.current = stream;

      if (videoRef.current) {
        videoRef.current.srcObject = stream;
        await videoRef.current.play();
        setIsReady(true);
      }
    } catch (err) {
      console.error('Camera error:', err);
      setError(err.name === 'NotAllowedError' 
        ? 'Camera permission denied. Please enable camera access.'
        : 'Failed to access camera. Please try again.'
      );
      setIsReady(false);
    }
  }, [facingMode]);

  // Stop camera
  const stopCamera = useCallback(() => {
    if (streamRef.current) {
      streamRef.current.getTracks().forEach(track => track.stop());
      streamRef.current = null;
    }
    if (videoRef.current) {
      videoRef.current.srcObject = null;
    }
    setIsReady(false);
  }, []);

  // Toggle front/back camera
  const toggleCamera = useCallback(() => {
    setFacingMode(prev => prev === 'user' ? 'environment' : 'user');
  }, []);

  // Restart camera when facing mode changes
  useEffect(() => {
    if (isReady) {
      startCamera();
    }
  }, [facingMode]);

  // Capture photo
  const capturePhoto = useCallback(() => {
    if (!videoRef.current || !isReady) return null;

    const video = videoRef.current;
    const canvas = canvasRef.current || document.createElement('canvas');
    
    // Set canvas size to match video
    canvas.width = video.videoWidth;
    canvas.height = video.videoHeight;
    
    const ctx = canvas.getContext('2d');
    
    // Mirror the image for front camera
    if (facingMode === 'user') {
      ctx.translate(canvas.width, 0);
      ctx.scale(-1, 1);
    }
    
    ctx.drawImage(video, 0, 0);
    
    // Reset transform
    ctx.setTransform(1, 0, 0, 1, 0, 0);

    // Get image data
    const imageData = canvas.toDataURL('image/jpeg', 0.92);
    
    // Get metadata
    const metadata = {
      width: canvas.width,
      height: canvas.height,
      timestamp: new Date().toISOString(),
      facingMode,
    };

    return { imageData, metadata };
  }, [isReady, facingMode]);

  // Analyze image quality
  const analyzeQuality = useCallback((imageData) => {
    return new Promise((resolve) => {
      const img = new Image();
      img.onload = () => {
        const canvas = document.createElement('canvas');
        canvas.width = img.width;
        canvas.height = img.height;
        const ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0);
        
        const data = ctx.getImageData(0, 0, canvas.width, canvas.height).data;
        
        // Calculate brightness
        let totalBrightness = 0;
        for (let i = 0; i < data.length; i += 4) {
          totalBrightness += (data[i] + data[i + 1] + data[i + 2]) / 3;
        }
        const avgBrightness = totalBrightness / (data.length / 4);
        const brightnessScore = Math.min(100, Math.max(0, 
          100 - Math.abs(avgBrightness - 128) * 1.5
        ));

        // Calculate contrast (standard deviation of brightness)
        let variance = 0;
        for (let i = 0; i < data.length; i += 4) {
          const brightness = (data[i] + data[i + 1] + data[i + 2]) / 3;
          variance += Math.pow(brightness - avgBrightness, 2);
        }
        const stdDev = Math.sqrt(variance / (data.length / 4));
        const contrastScore = Math.min(100, stdDev * 2);

        // Calculate sharpness (edge detection approximation)
        let edgeStrength = 0;
        const width = canvas.width;
        for (let i = 0; i < data.length - 4 * width; i += 4) {
          const current = (data[i] + data[i + 1] + data[i + 2]) / 3;
          const right = (data[i + 4] + data[i + 5] + data[i + 6]) / 3;
          const below = (data[i + width * 4] + data[i + width * 4 + 1] + data[i + width * 4 + 2]) / 3;
          edgeStrength += Math.abs(current - right) + Math.abs(current - below);
        }
        const sharpnessScore = Math.min(100, (edgeStrength / (data.length / 4)) * 10);

        // Overall quality score
        const overallScore = (brightnessScore * 0.3 + contrastScore * 0.3 + sharpnessScore * 0.4);

        resolve({
          brightness: Math.round(brightnessScore),
          contrast: Math.round(contrastScore),
          sharpness: Math.round(sharpnessScore),
          overall: Math.round(overallScore),
          isAcceptable: overallScore >= 50 && brightnessScore >= 40 && sharpnessScore >= 30,
          feedback: getQualityFeedback(brightnessScore, contrastScore, sharpnessScore),
        });
      };
      img.src = imageData;
    });
  }, []);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      stopCamera();
    };
  }, [stopCamera]);

  return {
    videoRef,
    canvasRef,
    isReady,
    error,
    facingMode,
    startCamera,
    stopCamera,
    toggleCamera,
    capturePhoto,
    analyzeQuality,
  };
}

function getQualityFeedback(brightness, contrast, sharpness) {
  const issues = [];
  
  if (brightness < 40) {
    issues.push('Too dark. Find better lighting.');
  } else if (brightness < 60) {
    issues.push('Lighting could be improved.');
  }
  
  if (sharpness < 30) {
    issues.push('Image is blurry. Hold steady.');
  } else if (sharpness < 50) {
    issues.push('Try to keep the camera more stable.');
  }
  
  if (contrast < 40) {
    issues.push('Low contrast. Adjust lighting angle.');
  }
  
  if (issues.length === 0) {
    return 'Good quality capture.';
  }
  
  return issues.join(' ');
}

export default useCamera;

