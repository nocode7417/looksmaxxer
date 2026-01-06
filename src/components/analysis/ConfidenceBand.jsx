import { motion } from 'framer-motion';

export function ConfidenceBand({
  value,
  range,
  min = 0,
  max = 100,
  showLabels = true,
  className = '',
}) {
  const [low, high] = range;
  const valuePercent = ((value - min) / (max - min)) * 100;
  const lowPercent = ((low - min) / (max - min)) * 100;
  const highPercent = ((high - min) / (max - min)) * 100;
  const rangeWidth = highPercent - lowPercent;

  return (
    <div className={`w-full ${className}`}>
      <div className="relative w-full h-10">
        {/* Track background */}
        <div className="absolute top-1/2 -translate-y-1/2 w-full h-1.5 bg-[var(--color-surface-elevated)] rounded-full" />
        
        {/* Confidence range band */}
        <motion.div
          className="absolute top-1/2 -translate-y-1/2 h-2 bg-[var(--color-border)] rounded-full"
          initial={{ width: 0, opacity: 0 }}
          animate={{ 
            width: `${rangeWidth}%`, 
            left: `${lowPercent}%`,
            opacity: 1 
          }}
          transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1], delay: 0.2 }}
        />
        
        {/* Range markers */}
        <motion.div
          className="absolute top-1/2 w-0.5 h-3 bg-[var(--color-text-muted)] rounded-full"
          initial={{ opacity: 0 }}
          animate={{ left: `${lowPercent}%`, opacity: 0.5, y: '-50%' }}
          transition={{ duration: 0.6, delay: 0.4 }}
        />
        <motion.div
          className="absolute top-1/2 w-0.5 h-3 bg-[var(--color-text-muted)] rounded-full"
          initial={{ opacity: 0 }}
          animate={{ left: `${highPercent}%`, opacity: 0.5, y: '-50%' }}
          transition={{ duration: 0.6, delay: 0.4 }}
        />
        
        {/* Value marker */}
        <motion.div
          className="absolute top-1/2"
          initial={{ left: `${lowPercent}%`, opacity: 0 }}
          animate={{ left: `${valuePercent}%`, opacity: 1 }}
          transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1], delay: 0.5 }}
          style={{ transform: 'translate(-50%, -50%)' }}
        >
          <div className="w-4 h-4 bg-[var(--color-text-primary)] rounded-full shadow-lg" />
        </motion.div>
      </div>
      
      {/* Labels */}
      {showLabels && (
        <div className="flex justify-between mt-1 px-1">
          <span className="text-[11px] text-[var(--color-text-muted)]">{min}</span>
          <div className="flex items-center gap-1">
            <span className="text-[11px] text-[var(--color-text-tertiary)]">
              {low} – {high}
            </span>
          </div>
          <span className="text-[11px] text-[var(--color-text-muted)]">{max}</span>
        </div>
      )}
    </div>
  );
}

export default ConfidenceBand;

