import { motion } from 'framer-motion';
import { Lock, Calendar, Image } from 'lucide-react';
import { staggerChildren, staggerItem } from '../../utils/animations';

export function TimelineTab({ timeline, stats }) {
  const hasPhotos = timeline.length > 0;

  return (
    <div className="px-6 pt-6 pb-8">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-6"
      >
        <h1 className="text-[28px] font-semibold text-[var(--color-text-primary)] tracking-[-0.02em] mb-1">
          Timeline
        </h1>
        <p className="text-[15px] text-[var(--color-text-secondary)]">
          Your progress captured over time
        </p>
      </motion.div>

      {/* Stats */}
      {hasPhotos && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="grid grid-cols-3 gap-3 mb-6"
        >
          <StatCard label="Photos" value={stats.totalPhotos} />
          <StatCard label="Days" value={stats.daysCovered} />
          <StatCard label="Confidence" value={`${stats.avgConfidence}%`} />
        </motion.div>
      )}

      {/* Timeline grid */}
      {hasPhotos ? (
        <motion.div
          variants={staggerChildren}
          initial="initial"
          animate="animate"
        >
          {/* Info banner */}
          <motion.div
            variants={staggerItem}
            className="flex items-center gap-2 p-3 bg-[var(--color-surface)] rounded-[10px] border border-[var(--color-border-subtle)] mb-4"
          >
            <Lock size={14} className="text-[var(--color-text-tertiary)]" />
            <span className="text-[12px] text-[var(--color-text-tertiary)]">
              Photos are locked and cannot be deleted
            </span>
          </motion.div>

          {/* Photo grid */}
          <div className="grid grid-cols-3 gap-1">
            {timeline.map((entry, index) => (
              <motion.div
                key={entry.id}
                variants={staggerItem}
                className="aspect-square relative bg-[var(--color-surface)] rounded-[8px] overflow-hidden"
              >
                {/* Placeholder - in real app would load from IndexedDB */}
                <div className="absolute inset-0 flex items-center justify-center bg-[var(--color-surface-elevated)]">
                  <Image size={24} className="text-[var(--color-text-muted)]" />
                </div>
                
                {/* Date overlay */}
                <div className="absolute bottom-0 left-0 right-0 p-1.5 bg-gradient-to-t from-black/60 to-transparent">
                  <p className="text-[10px] text-white/80 font-medium">
                    {formatShortDate(entry.date)}
                  </p>
                </div>

                {/* Confidence indicator */}
                <div className="absolute top-1.5 right-1.5">
                  <div 
                    className={`w-2 h-2 rounded-full ${
                      entry.confidence >= 0.8 ? 'bg-[#22c55e]' :
                      entry.confidence >= 0.5 ? 'bg-[#f59e0b]' :
                      'bg-[#ef4444]'
                    }`}
                  />
                </div>
              </motion.div>
            ))}
          </div>
        </motion.div>
      ) : (
        <EmptyState />
      )}
    </div>
  );
}

function StatCard({ label, value }) {
  return (
    <div className="bg-[var(--color-surface)] rounded-[10px] p-3 border border-[var(--color-border-subtle)]">
      <p className="text-[20px] font-semibold text-[var(--color-text-primary)] mb-0.5">
        {value}
      </p>
      <p className="text-[11px] text-[var(--color-text-tertiary)]">
        {label}
      </p>
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
        <Calendar size={28} className="text-[var(--color-text-muted)]" />
      </div>
      <h3 className="text-[17px] font-semibold text-[var(--color-text-secondary)] mb-2">
        No photos yet
      </h3>
      <p className="text-[15px] text-[var(--color-text-tertiary)] text-center max-w-[240px]">
        Your photo timeline will appear here as you track your progress
      </p>
    </motion.div>
  );
}

function formatShortDate(dateString) {
  const date = new Date(dateString);
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
  });
}

export default TimelineTab;

