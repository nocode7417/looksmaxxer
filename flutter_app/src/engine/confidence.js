// Confidence and uncertainty modeling

// Generate confidence level based on variance
export function generateConfidence(actualVariance, varianceRange) {
  const { min, max } = varianceRange;
  const normalizedVariance = (actualVariance - min) / (max - min);
  
  if (normalizedVariance <= 0.33) return 'high';
  if (normalizedVariance <= 0.66) return 'medium';
  return 'low';
}

// Add realistic variance to a value
export function addVariance(baseValue, varianceAmount, range) {
  const [min, max] = range;
  const variance = (Math.random() - 0.5) * varianceAmount * 2;
  return Math.max(min, Math.min(max, baseValue + variance));
}

// Calculate confidence score (0-1) from multiple factors
export function calculateOverallConfidence(factors) {
  const weights = {
    photoQuality: 0.3,
    consistency: 0.25,
    sampleSize: 0.25,
    timespan: 0.2,
  };
  
  let totalWeight = 0;
  let weightedSum = 0;
  
  for (const [factor, value] of Object.entries(factors)) {
    if (weights[factor] !== undefined) {
      weightedSum += value * weights[factor];
      totalWeight += weights[factor];
    }
  }
  
  return totalWeight > 0 ? weightedSum / totalWeight : 0.5;
}

// Determine if a change is statistically significant
export function isSignificantChange(currentValue, previousValue, variance) {
  const change = Math.abs(currentValue - previousValue);
  // Change must exceed variance to be considered significant
  return change > variance * 1.5;
}

// Calculate moving average for smoothing metrics
export function calculateMovingAverage(values, windowSize = 5) {
  if (values.length === 0) return null;
  if (values.length < windowSize) {
    return values.reduce((a, b) => a + b, 0) / values.length;
  }
  
  const window = values.slice(-windowSize);
  return window.reduce((a, b) => a + b, 0) / windowSize;
}

// Calculate weighted moving average (more recent = more weight)
export function calculateWeightedMovingAverage(values, windowSize = 5) {
  if (values.length === 0) return null;
  
  const window = values.slice(-windowSize);
  let weightedSum = 0;
  let totalWeight = 0;
  
  window.forEach((value, index) => {
    const weight = index + 1; // Linear weighting
    weightedSum += value * weight;
    totalWeight += weight;
  });
  
  return weightedSum / totalWeight;
}

// Format confidence for display
export function formatConfidence(confidence) {
  const levels = {
    high: { label: 'High', color: 'success', description: 'Reliable measurement' },
    medium: { label: 'Medium', color: 'warning', description: 'Some variance expected' },
    low: { label: 'Low', color: 'error', description: 'High uncertainty' },
  };
  
  return levels[confidence] || levels.medium;
}

// Calculate days until confident progress measurement
export function daysUntilConfidentProgress(startDate, minDays = 14, minSamples = 7, currentSamples = 0) {
  const daysSinceStart = Math.floor(
    (Date.now() - new Date(startDate).getTime()) / (1000 * 60 * 60 * 24)
  );
  
  const daysRemaining = Math.max(0, minDays - daysSinceStart);
  const samplesNeeded = Math.max(0, minSamples - currentSamples);
  
  return {
    daysRemaining,
    samplesNeeded,
    isReady: daysRemaining === 0 && samplesNeeded === 0,
    progress: Math.min(1, (daysSinceStart / minDays + currentSamples / minSamples) / 2),
  };
}

export default {
  generateConfidence,
  addVariance,
  calculateOverallConfidence,
  isSignificantChange,
  calculateMovingAverage,
  calculateWeightedMovingAverage,
  formatConfidence,
  daysUntilConfidentProgress,
};

