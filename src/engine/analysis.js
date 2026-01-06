// Mock Facial Analysis Engine
// Generates realistic, science-backed metrics with appropriate variance

import { generateConfidence, addVariance } from './confidence';

// Metric definitions with scientific basis
const METRIC_DEFINITIONS = {
  symmetry: {
    name: 'Facial Symmetry',
    description: 'Bilateral comparison of facial features',
    unit: 'score',
    range: [0, 100],
    baseline: { min: 65, max: 92 },
    variance: { min: 3, max: 8 },
    factors: ['Sleep quality', 'Hydration', 'Stress levels', 'Posture'],
    scientific: 'Measured as deviation between left and right facial landmarks',
  },
  proportions: {
    name: 'Proportional Harmony',
    description: 'Facial thirds ratio analysis',
    unit: 'deviation',
    range: [-15, 15],
    baseline: { min: -8, max: 8 },
    variance: { min: 1, max: 4 },
    factors: ['Angle of capture', 'Expression', 'Head tilt'],
    scientific: 'Deviation from ideal 1:1:1 facial thirds ratio',
  },
  canthalTilt: {
    name: 'Canthal Tilt',
    description: 'Angle between inner and outer eye corners',
    unit: 'degrees',
    range: [-10, 15],
    baseline: { min: -3, max: 8 },
    variance: { min: 0.5, max: 2 },
    factors: ['Sleep', 'Fluid retention', 'Age'],
    scientific: 'Positive values indicate upward tilt (lateral canthus higher)',
  },
  skinTexture: {
    name: 'Skin Texture',
    description: 'Surface uniformity and hydration markers',
    unit: 'score',
    range: [0, 100],
    baseline: { min: 55, max: 88 },
    variance: { min: 5, max: 12 },
    factors: ['Hydration', 'Sleep', 'Skincare routine', 'Diet', 'Stress'],
    scientific: 'Composite of local variance, pore visibility, and color uniformity',
  },
  skinClarity: {
    name: 'Skin Clarity',
    description: 'Pigmentation evenness and inflammation markers',
    unit: 'score',
    range: [0, 100],
    baseline: { min: 50, max: 90 },
    variance: { min: 4, max: 10 },
    factors: ['Sun exposure', 'Skincare', 'Diet', 'Hormones'],
    scientific: 'Analysis of color distribution and localized irregularities',
  },
  jawDefinition: {
    name: 'Jaw Definition',
    description: 'Mandibular contour sharpness',
    unit: 'score',
    range: [0, 100],
    baseline: { min: 45, max: 85 },
    variance: { min: 3, max: 8 },
    factors: ['Body fat', 'Posture', 'Mewing practice', 'Hydration'],
    scientific: 'Edge detection strength along mandibular line',
  },
  cheekboneProminence: {
    name: 'Cheekbone Prominence',
    description: 'Zygomatic projection analysis',
    unit: 'score',
    range: [0, 100],
    baseline: { min: 40, max: 82 },
    variance: { min: 4, max: 9 },
    factors: ['Lighting angle', 'Body fat', 'Facial exercises'],
    scientific: 'Shadow depth analysis in malar region',
  },
};

// Generate a single metric analysis
function generateMetric(definition, seed = Math.random()) {
  const { baseline, variance, range } = definition;
  
  // Generate base value within realistic range
  const baseValue = baseline.min + (seed * (baseline.max - baseline.min));
  
  // Calculate variance for confidence interval
  const metricVariance = variance.min + (Math.random() * (variance.max - variance.min));
  
  // Calculate confidence range
  const low = Math.max(range[0], baseValue - metricVariance);
  const high = Math.min(range[1], baseValue + metricVariance);
  
  // Determine confidence level based on variance
  const confidence = generateConfidence(metricVariance, variance);
  
  return {
    value: Math.round(baseValue * 10) / 10,
    range: [Math.round(low * 10) / 10, Math.round(high * 10) / 10],
    confidence,
    variance: Math.round(metricVariance * 10) / 10,
  };
}

// Main analysis function
export async function analyzePhoto(imageData, existingBaseline = null) {
  // Simulate processing delay (anti-dopamine)
  await new Promise(resolve => setTimeout(resolve, 2000 + Math.random() * 1500));
  
  // Generate seed based on image data for consistency
  const seed = generateSeedFromImage(imageData);
  
  const metrics = {};
  
  for (const [key, definition] of Object.entries(METRIC_DEFINITIONS)) {
    // If there's an existing baseline, add realistic variance
    if (existingBaseline && existingBaseline[key]) {
      metrics[key] = {
        ...generateMetric(definition, seed + Object.keys(metrics).length * 0.1),
        ...definition,
        previous: existingBaseline[key].value,
        change: calculateChange(existingBaseline[key].value, definition),
      };
    } else {
      metrics[key] = {
        ...generateMetric(definition, seed + Object.keys(metrics).length * 0.1),
        ...definition,
      };
    }
  }
  
  // Calculate overall confidence
  const confidenceLevels = Object.values(metrics).map(m => 
    m.confidence === 'high' ? 3 : m.confidence === 'medium' ? 2 : 1
  );
  const avgConfidence = confidenceLevels.reduce((a, b) => a + b, 0) / confidenceLevels.length;
  
  return {
    metrics,
    analyzedAt: new Date().toISOString(),
    overallConfidence: avgConfidence >= 2.5 ? 'high' : avgConfidence >= 1.5 ? 'medium' : 'low',
    photoQuality: 0.7 + Math.random() * 0.25, // Simulated quality score
  };
}

// Generate consistent seed from image data
function generateSeedFromImage(imageData) {
  // Simple hash-like function for consistency
  let hash = 0;
  const str = imageData.slice(100, 500); // Sample portion of data
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash;
  }
  return Math.abs(hash % 1000) / 1000;
}

// Calculate realistic change from previous measurement
function calculateChange(previousValue, definition) {
  // Changes should be small and slow (anti-gaming)
  const maxChange = (definition.variance.max - definition.variance.min) * 0.3;
  const change = (Math.random() - 0.5) * maxChange * 2;
  return Math.round(change * 10) / 10;
}

// Get metric definitions for UI
export function getMetricDefinitions() {
  return METRIC_DEFINITIONS;
}

// Get specific metric info
export function getMetricInfo(metricKey) {
  return METRIC_DEFINITIONS[metricKey] || null;
}

export default analyzePhoto;

