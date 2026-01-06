// Metric calculation utilities

// Format metric value for display
export function formatMetricValue(value, unit) {
  switch (unit) {
    case 'score':
      return Math.round(value).toString();
    case 'degrees':
      return `${value > 0 ? '+' : ''}${value.toFixed(1)}°`;
    case 'deviation':
      return `${value > 0 ? '+' : ''}${value.toFixed(1)}`;
    case 'percentage':
      return `${Math.round(value)}%`;
    default:
      return value.toString();
  }
}

// Format metric range for display
export function formatMetricRange(range, unit) {
  const [low, high] = range;
  switch (unit) {
    case 'score':
      return `${Math.round(low)} – ${Math.round(high)}`;
    case 'degrees':
      return `${low.toFixed(1)}° – ${high.toFixed(1)}°`;
    case 'deviation':
      return `${low.toFixed(1)} – ${high.toFixed(1)}`;
    default:
      return `${low} – ${high}`;
  }
}

// Get metric status based on value and optimal range
export function getMetricStatus(value, optimalRange = [0, 100]) {
  const [optimalLow, optimalHigh] = optimalRange;
  const midpoint = (optimalLow + optimalHigh) / 2;
  const distance = Math.abs(value - midpoint) / (optimalHigh - optimalLow);
  
  if (distance <= 0.25) return 'optimal';
  if (distance <= 0.5) return 'good';
  if (distance <= 0.75) return 'moderate';
  return 'attention';
}

// Calculate improvement potential
export function calculatePotential(current, range, optimizationFactor = 0.3) {
  const [low, high] = range;
  const maxImprovement = (high - current) * optimizationFactor;
  
  return {
    currentValue: current,
    potentialValue: Math.min(high, current + maxImprovement),
    improvementRange: maxImprovement,
    isNearOptimal: (high - current) / (high - low) < 0.2,
  };
}

// Compare two metric snapshots
export function compareMetrics(current, previous) {
  if (!previous) return null;
  
  const changes = {};
  
  for (const [key, currentMetric] of Object.entries(current)) {
    const previousMetric = previous[key];
    if (!previousMetric) continue;
    
    const change = currentMetric.value - previousMetric.value;
    const percentChange = (change / previousMetric.value) * 100;
    
    changes[key] = {
      absolute: change,
      percent: percentChange,
      direction: change > 0 ? 'improved' : change < 0 ? 'declined' : 'stable',
      isSignificant: Math.abs(change) > currentMetric.variance,
    };
  }
  
  return changes;
}

// Aggregate metrics into categories
export function aggregateMetrics(metrics) {
  const categories = {
    structure: ['symmetry', 'proportions', 'jawDefinition', 'cheekboneProminence'],
    skin: ['skinTexture', 'skinClarity'],
    features: ['canthalTilt'],
  };
  
  const aggregated = {};
  
  for (const [category, metricKeys] of Object.entries(categories)) {
    const categoryMetrics = metricKeys
      .filter(key => metrics[key])
      .map(key => metrics[key]);
    
    if (categoryMetrics.length === 0) continue;
    
    const avgValue = categoryMetrics.reduce((sum, m) => sum + m.value, 0) / categoryMetrics.length;
    const avgConfidence = categoryMetrics.reduce((sum, m) => {
      const confScore = m.confidence === 'high' ? 3 : m.confidence === 'medium' ? 2 : 1;
      return sum + confScore;
    }, 0) / categoryMetrics.length;
    
    aggregated[category] = {
      value: Math.round(avgValue * 10) / 10,
      confidence: avgConfidence >= 2.5 ? 'high' : avgConfidence >= 1.5 ? 'medium' : 'low',
      metrics: categoryMetrics.length,
    };
  }
  
  return aggregated;
}

// Get metric icon name
export function getMetricIcon(metricKey) {
  const icons = {
    symmetry: 'Symmetry',
    proportions: 'Proportions',
    canthalTilt: 'Eye',
    skinTexture: 'Skin',
    skinClarity: 'Skin',
    jawDefinition: 'Structure',
    cheekboneProminence: 'Structure',
  };
  
  return icons[metricKey] || 'Chart';
}

// Get metric category
export function getMetricCategory(metricKey) {
  const categories = {
    symmetry: 'structure',
    proportions: 'structure',
    canthalTilt: 'features',
    skinTexture: 'skin',
    skinClarity: 'skin',
    jawDefinition: 'structure',
    cheekboneProminence: 'structure',
  };
  
  return categories[metricKey] || 'other';
}

export default {
  formatMetricValue,
  formatMetricRange,
  getMetricStatus,
  calculatePotential,
  compareMetrics,
  aggregateMetrics,
  getMetricIcon,
  getMetricCategory,
};

