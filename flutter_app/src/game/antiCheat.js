// Anti-cheat and quality validation system
// Designed to detect filters, angles, and gaming behavior

// Quality thresholds
const QUALITY_THRESHOLDS = {
  minBrightness: 30,
  maxBrightness: 90,
  minSharpness: 25,
  minContrast: 30,
  minFaceSize: 0.2, // 20% of frame
  maxFaceSize: 0.7, // 70% of frame
};

// Validate photo meets capture requirements
export function validatePhoto(qualityMetrics) {
  const issues = [];
  const { brightness, sharpness, contrast, faceSize } = qualityMetrics;

  if (brightness < QUALITY_THRESHOLDS.minBrightness) {
    issues.push({
      type: 'brightness_low',
      message: 'Lighting is too dark',
      severity: 'error',
    });
  } else if (brightness > QUALITY_THRESHOLDS.maxBrightness) {
    issues.push({
      type: 'brightness_high',
      message: 'Lighting is too bright',
      severity: 'warning',
    });
  }

  if (sharpness < QUALITY_THRESHOLDS.minSharpness) {
    issues.push({
      type: 'blur',
      message: 'Image is blurry',
      severity: 'error',
    });
  }

  if (contrast < QUALITY_THRESHOLDS.minContrast) {
    issues.push({
      type: 'contrast_low',
      message: 'Low contrast detected',
      severity: 'warning',
    });
  }

  if (faceSize !== undefined) {
    if (faceSize < QUALITY_THRESHOLDS.minFaceSize) {
      issues.push({
        type: 'face_small',
        message: 'Move closer to camera',
        severity: 'warning',
      });
    } else if (faceSize > QUALITY_THRESHOLDS.maxFaceSize) {
      issues.push({
        type: 'face_large',
        message: 'Move back from camera',
        severity: 'warning',
      });
    }
  }

  const hasErrors = issues.some(i => i.severity === 'error');
  const hasWarnings = issues.some(i => i.severity === 'warning');

  return {
    isValid: !hasErrors,
    hasWarnings,
    issues,
    confidence: calculateConfidenceFromIssues(issues),
  };
}

// Calculate confidence score based on validation issues
function calculateConfidenceFromIssues(issues) {
  let confidence = 1.0;

  for (const issue of issues) {
    if (issue.severity === 'error') {
      confidence -= 0.3;
    } else if (issue.severity === 'warning') {
      confidence -= 0.1;
    }
  }

  return Math.max(0.1, confidence);
}

// Detect potential filter usage
export function detectFilters(imageData, metadata) {
  const flags = [];
  
  // Check for unnaturally smooth gradients (beauty filters)
  // In a real implementation, this would analyze pixel variance
  const suspiciousSmoothing = false; // Placeholder
  if (suspiciousSmoothing) {
    flags.push({
      type: 'smoothing_detected',
      confidence: 0.7,
      message: 'Possible smoothing filter detected',
    });
  }

  // Check for unnatural color grading
  // Real implementation would analyze color histogram
  const suspiciousColors = false; // Placeholder
  if (suspiciousColors) {
    flags.push({
      type: 'color_filter_detected',
      confidence: 0.6,
      message: 'Unusual color processing detected',
    });
  }

  // Check metadata for editing software signatures
  if (metadata.software && isEditingSoftware(metadata.software)) {
    flags.push({
      type: 'editing_software',
      confidence: 0.9,
      message: 'Image was processed in editing software',
    });
  }

  return {
    isProbablyFiltered: flags.length > 0,
    flags,
    overallConfidence: flags.length > 0 
      ? 1 - (flags.reduce((sum, f) => sum + f.confidence, 0) / flags.length) * 0.5
      : 1.0,
  };
}

// Check if software name indicates editing
function isEditingSoftware(software) {
  const editingSoftware = [
    'photoshop', 'lightroom', 'snapseed', 'vsco', 
    'facetune', 'beautycam', 'meitu', 'snow',
  ];
  
  const lowerSoftware = software.toLowerCase();
  return editingSoftware.some(s => lowerSoftware.includes(s));
}

// Detect angle manipulation
export function detectAngleManipulation(currentMetadata, historicalMetadata) {
  if (!historicalMetadata || historicalMetadata.length < 3) {
    return { isConsistent: true, flags: [] };
  }

  const flags = [];

  // Check for sudden changes in face position/angle
  // In real implementation, this would compare face landmarks
  
  // For demo, we'll do basic timestamp analysis
  const timestamps = historicalMetadata.map(m => new Date(m.timestamp).getTime());
  const currentTime = new Date(currentMetadata.timestamp).getTime();
  
  // Check for suspiciously quick succession (potential cherry-picking)
  const recentUploads = timestamps.filter(t => currentTime - t < 60000); // Within 1 minute
  if (recentUploads.length > 3) {
    flags.push({
      type: 'rapid_captures',
      message: 'Multiple rapid captures detected',
      confidence: 0.6,
    });
  }

  return {
    isConsistent: flags.length === 0,
    flags,
    confidencePenalty: flags.length * 0.15,
  };
}

// Calculate overall trust score for a photo
export function calculateTrustScore(validationResult, filterResult, angleResult) {
  let score = 1.0;

  // Apply validation confidence
  score *= validationResult.confidence;

  // Apply filter detection penalty
  if (filterResult.isProbablyFiltered) {
    score *= filterResult.overallConfidence;
  }

  // Apply angle consistency penalty
  if (!angleResult.isConsistent) {
    score -= angleResult.confidencePenalty;
  }

  return {
    score: Math.max(0.1, Math.min(1.0, score)),
    level: getTrustLevel(score),
    message: getTrustMessage(score, validationResult, filterResult, angleResult),
  };
}

function getTrustLevel(score) {
  if (score >= 0.8) return 'high';
  if (score >= 0.5) return 'medium';
  return 'low';
}

function getTrustMessage(score, validation, filter, angle) {
  if (score >= 0.8) {
    return 'High-quality capture suitable for analysis';
  }
  
  if (!validation.isValid) {
    return 'Photo quality issues may affect accuracy';
  }
  
  if (filter.isProbablyFiltered) {
    return 'Possible image processing detected';
  }
  
  if (!angle.isConsistent) {
    return 'Capture conditions vary from baseline';
  }
  
  return 'Moderate confidence in capture quality';
}

// Rate limiting for uploads
const uploadTimestamps = [];
const MAX_UPLOADS_PER_HOUR = 10;
const MAX_UPLOADS_PER_DAY = 20;

export function checkRateLimit() {
  const now = Date.now();
  const hourAgo = now - 60 * 60 * 1000;
  const dayAgo = now - 24 * 60 * 60 * 1000;

  const uploadsLastHour = uploadTimestamps.filter(t => t > hourAgo).length;
  const uploadsLastDay = uploadTimestamps.filter(t => t > dayAgo).length;

  if (uploadsLastHour >= MAX_UPLOADS_PER_HOUR) {
    return {
      allowed: false,
      reason: 'hourly_limit',
      message: 'Too many uploads this hour. Quality over quantity.',
      retryAfter: Math.ceil((uploadTimestamps.find(t => t > hourAgo) + 60 * 60 * 1000 - now) / 60000),
    };
  }

  if (uploadsLastDay >= MAX_UPLOADS_PER_DAY) {
    return {
      allowed: false,
      reason: 'daily_limit',
      message: 'Daily upload limit reached. Return tomorrow.',
      retryAfter: Math.ceil((uploadTimestamps.find(t => t > dayAgo) + 24 * 60 * 60 * 1000 - now) / 60000),
    };
  }

  return { allowed: true };
}

export function recordUpload() {
  uploadTimestamps.push(Date.now());
  // Clean old timestamps
  const dayAgo = Date.now() - 24 * 60 * 60 * 1000;
  while (uploadTimestamps.length > 0 && uploadTimestamps[0] < dayAgo) {
    uploadTimestamps.shift();
  }
}

export default {
  validatePhoto,
  detectFilters,
  detectAngleManipulation,
  calculateTrustScore,
  checkRateLimit,
  recordUpload,
  QUALITY_THRESHOLDS,
};

