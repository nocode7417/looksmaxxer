import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronDown, Shapes, Ruler, Eye, Sparkles, Box } from 'lucide-react';
import { ConfidenceBand } from '../ui/Progress';
import { formatMetricValue, formatMetricRange } from '../../engine/metrics';

const METRIC_ICONS = {
  symmetry: Shapes,
  proportions: Ruler,
  canthalTilt: Eye,
  skinTexture: Sparkles,
  skinClarity: Sparkles,
  jawDefinition: Box,
  cheekboneProminence: Box,
};

export function MetricCard({ metricKey, metric }) {
  const [isExpanded, setIsExpanded] = useState(false);
  
  const Icon = METRIC_ICONS[metricKey] || Shapes;
  const formattedValue = formatMetricValue(metric.value, metric.unit);
  const formattedRange = formatMetricRange(metric.range, metric.unit);
  
  const confidenceColors = {
    high: 'text-[var(--color-success)]',
    medium: 'text-[var(--color-warning)]',
    low: 'text-[var(--color-error)]',
  };

  return (
    <motion.div
      layout
      className="bg-[var(--color-surface)] border border-[var(--color-border-subtle)] rounded-[12px] overflow-hidden"
    >
      {/* Main content */}
      <div className="p-4">
        {/* Header row */}
        <div className="flex items-start gap-3 mb-3">
          <div className="flex-shrink-0 w-10 h-10 rounded-[10px] bg-[var(--color-surface-elevated)] flex items-center justify-center">
            <Icon size={20} strokeWidth={1.5} className="text-[var(--color-text-secondary)]" />
          </div>
          
          <div className="flex-1 min-w-0">
            <h3 className="text-[15px] font-medium text-[var(--color-text-primary)]">
              {metric.name}
            </h3>
            <p className="text-[11px] text-[var(--color-text-tertiary)] mt-0.5">
              {metric.description}
            </p>
          </div>
        </div>

        {/* Value and confidence */}
        <div className="flex items-baseline gap-3 mb-3">
          <span className="text-[28px] font-semibold text-[var(--color-text-primary)] tracking-[-0.02em]">
            {formattedValue}
          </span>
          <span className={`text-[13px] font-medium ${confidenceColors[metric.confidence]}`}>
            {metric.confidence} confidence
          </span>
        </div>

        {/* Confidence band visualization */}
        {metric.unit === 'score' && (
          <ConfidenceBand
            value={metric.value}
            range={metric.range}
            min={metric.range[0] - 10}
            max={metric.range[1] + 10}
          />
        )}

        {/* Range display for non-score metrics */}
        {metric.unit !== 'score' && (
          <div className="flex items-center gap-2 mt-1">
            <span className="text-[11px] text-[var(--color-text-muted)]">
              Range: {formattedRange}
            </span>
          </div>
        )}
      </div>

      {/* Expandable section */}
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="w-full px-4 py-3 flex items-center justify-between border-t border-[var(--color-border-subtle)] hover:bg-[var(--color-surface-hover)] transition-colors"
      >
        <span className="text-[13px] text-[var(--color-text-secondary)]">
          What affects this?
        </span>
        <motion.div
          animate={{ rotate: isExpanded ? 180 : 0 }}
          transition={{ duration: 0.2 }}
        >
          <ChevronDown size={16} className="text-[var(--color-text-tertiary)]" />
        </motion.div>
      </button>

      <AnimatePresence>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="overflow-hidden"
          >
            <div className="px-4 pb-4 pt-1">
              {/* Factors */}
              <div className="mb-3">
                <p className="text-[11px] font-medium uppercase tracking-[0.08em] text-[var(--color-text-tertiary)] mb-2">
                  Influencing Factors
                </p>
                <div className="flex flex-wrap gap-1.5">
                  {metric.factors?.map((factor) => (
                    <span
                      key={factor}
                      className="px-2 py-1 text-[11px] text-[var(--color-text-secondary)] bg-[var(--color-surface-elevated)] rounded-[6px]"
                    >
                      {factor}
                    </span>
                  ))}
                </div>
              </div>

              {/* Scientific explanation */}
              <div>
                <p className="text-[11px] font-medium uppercase tracking-[0.08em] text-[var(--color-text-tertiary)] mb-2">
                  Measurement Method
                </p>
                <p className="text-[13px] text-[var(--color-text-secondary)] leading-relaxed">
                  {metric.scientific}
                </p>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  );
}

export default MetricCard;

