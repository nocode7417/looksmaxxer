import { motion } from 'framer-motion';

export function Progress({
  value = 0,
  max = 100,
  size = 'md',
  showLabel = false,
  className = '',
}) {
  const percentage = Math.min(Math.max((value / max) * 100, 0), 100);
  
  const sizes = {
    sm: 'h-1',
    md: 'h-1.5',
    lg: 'h-2',
  };

  return (
    <div className={`w-full ${className}`}>
      {showLabel && (
        <div className="flex justify-between mb-1.5">
          <span className="text-[11px] text-[var(--color-text-tertiary)]">Progress</span>
          <span className="text-[11px] text-[var(--color-text-secondary)] font-medium">
            {Math.round(percentage)}%
          </span>
        </div>
      )}
      <div className={`w-full bg-[var(--color-surface-elevated)] rounded-full overflow-hidden ${sizes[size]}`}>
        <motion.div
          className="h-full bg-[var(--color-text-primary)] rounded-full"
          initial={{ width: 0 }}
          animate={{ width: `${percentage}%` }}
          transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
        />
      </div>
    </div>
  );
}

export function ConfidenceBand({
  value,
  range,
  min = 0,
  max = 100,
  className = '',
}) {
  const [low, high] = range;
  const valuePercent = ((value - min) / (max - min)) * 100;
  const lowPercent = ((low - min) / (max - min)) * 100;
  const highPercent = ((high - min) / (max - min)) * 100;
  const rangeWidth = highPercent - lowPercent;

  return (
    <div className={`w-full ${className}`}>
      <div className="relative w-full h-8">
        {/* Track */}
        <div className="absolute top-1/2 -translate-y-1/2 w-full h-1 bg-[var(--color-surface-elevated)] rounded-full" />
        
        {/* Confidence range */}
        <motion.div
          className="absolute top-1/2 -translate-y-1/2 h-1.5 bg-[var(--color-border)] rounded-full"
          initial={{ width: 0, left: `${lowPercent}%` }}
          animate={{ width: `${rangeWidth}%`, left: `${lowPercent}%` }}
          transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1], delay: 0.2 }}
        />
        
        {/* Value marker */}
        <motion.div
          className="absolute top-1/2 -translate-y-1/2 w-3 h-3 bg-[var(--color-text-primary)] rounded-full shadow-sm"
          initial={{ left: 0, opacity: 0 }}
          animate={{ left: `${valuePercent}%`, opacity: 1, x: '-50%' }}
          transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1], delay: 0.4 }}
        />
      </div>
      
      {/* Labels */}
      <div className="flex justify-between mt-1">
        <span className="text-[11px] text-[var(--color-text-muted)]">{min}</span>
        <span className="text-[11px] text-[var(--color-text-muted)]">{max}</span>
      </div>
    </div>
  );
}

export default Progress;

