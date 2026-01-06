import { motion } from 'framer-motion';
import { Clock, TrendingUp } from 'lucide-react';
import { MetricCard } from '../analysis/MetricCard';
import { staggerChildren, staggerItem } from '../../utils/animations';

export function BaselineTab({ metrics, baselineDate, progression }) {
  const { confidenceProgress, progressInfo } = progression;

  if (!metrics) {
    return (
      <div className="px-6 pt-6 pb-8">
        <EmptyState />
      </div>
    );
  }

  const metricEntries = Object.entries(metrics).filter(
    ([key]) => key !== 'lastUpdated'
  );

  return (
    <div className="px-6 pt-6 pb-8">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-6"
      >
        <h1 className="text-[28px] font-semibold text-[var(--color-text-primary)] tracking-[-0.02em] mb-1">
          Baseline
        </h1>
        <p className="text-[15px] text-[var(--color-text-secondary)]">
          Your current measurements
        </p>
      </motion.div>

      {/* Last update info */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
        className="flex items-center gap-3 p-4 bg-[var(--color-surface)] rounded-[12px] border border-[var(--color-border-subtle)] mb-6"
      >
        <div className="w-10 h-10 rounded-[10px] bg-[var(--color-surface-elevated)] flex items-center justify-center">
          <Clock size={20} className="text-[var(--color-text-tertiary)]" />
        </div>
        <div className="flex-1">
          <p className="text-[13px] text-[var(--color-text-secondary)]">
            Baseline established
          </p>
          <p className="text-[15px] font-medium text-[var(--color-text-primary)]">
            {formatDate(baselineDate)}
          </p>
        </div>
        {!progressInfo.isLocked && (
          <div className="flex items-center gap-1 text-[var(--color-success)]">
            <TrendingUp size={16} />
            <span className="text-[13px] font-medium">Active</span>
          </div>
        )}
      </motion.div>

      {/* Update timing */}
      {confidenceProgress && !confidenceProgress.isReady && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.15 }}
          className="mb-6"
        >
          <div className="p-4 bg-[var(--color-surface)] rounded-[12px] border border-[var(--color-border-subtle)]">
            <div className="flex justify-between items-center mb-2">
              <span className="text-[13px] text-[var(--color-text-secondary)]">
                Next confident update
              </span>
              <span className="text-[13px] font-medium text-[var(--color-text-primary)]">
                {Math.round(confidenceProgress.progress * 100)}%
              </span>
            </div>
            <div className="w-full h-1.5 bg-[var(--color-surface-elevated)] rounded-full overflow-hidden">
              <motion.div
                className="h-full bg-[var(--color-text-tertiary)]"
                initial={{ width: 0 }}
                animate={{ width: `${confidenceProgress.progress * 100}%` }}
                transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
              />
            </div>
            <p className="text-[11px] text-[var(--color-text-muted)] mt-2">
              {confidenceProgress.daysRemaining > 0 
                ? `${confidenceProgress.daysRemaining} days and ${confidenceProgress.samplesNeeded} more photos needed`
                : `${confidenceProgress.samplesNeeded} more photos needed`
              }
            </p>
          </div>
        </motion.div>
      )}

      {/* Metrics list */}
      <motion.div
        variants={staggerChildren}
        initial="initial"
        animate="animate"
        className="space-y-3"
      >
        {metricEntries.map(([key, metric]) => (
          <motion.div key={key} variants={staggerItem}>
            <MetricCard metricKey={key} metric={metric} />
          </motion.div>
        ))}
      </motion.div>

      {/* Disclaimer */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.5 }}
        className="mt-6 text-center"
      >
        <p className="text-[11px] text-[var(--color-text-muted)] leading-relaxed">
          Metrics update slowly to ensure accuracy.
          <br />
          Meaningful changes require consistent data.
        </p>
      </motion.div>
    </div>
  );
}

function EmptyState() {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      className="flex flex-col items-center justify-center py-16"
    >
      <div className="w-16 h-16 rounded-full bg-[var(--color-surface)] flex items-center justify-center mb-4">
        <TrendingUp size={28} className="text-[var(--color-text-muted)]" />
      </div>
      <h3 className="text-[17px] font-semibold text-[var(--color-text-secondary)] mb-2">
        No baseline yet
      </h3>
      <p className="text-[15px] text-[var(--color-text-tertiary)] text-center max-w-[240px]">
        Complete your initial analysis to establish your baseline
      </p>
    </motion.div>
  );
}

function formatDate(dateString) {
  if (!dateString) return 'Not set';
  const date = new Date(dateString);
  return date.toLocaleDateString('en-US', {
    month: 'long',
    day: 'numeric',
    year: 'numeric',
  });
}

export default BaselineTab;

