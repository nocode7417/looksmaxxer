import { motion } from 'framer-motion';
import { Image, Lock, Calendar } from 'lucide-react';
import { staggerChildren, staggerItem } from '../../utils/animations';

export function Timeline({ entries, onEntryClick }) {
  if (entries.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-12">
        <div className="w-14 h-14 rounded-full bg-[var(--color-surface-elevated)] flex items-center justify-center mb-3">
          <Calendar size={24} className="text-[var(--color-text-muted)]" />
        </div>
        <p className="text-[15px] text-[var(--color-text-secondary)]">
          No entries yet
        </p>
      </div>
    );
  }

  // Group entries by month
  const grouped = groupByMonth(entries);

  return (
    <motion.div
      variants={staggerChildren}
      initial="initial"
      animate="animate"
      className="space-y-6"
    >
      {Object.entries(grouped).map(([month, monthEntries]) => (
        <motion.div key={month} variants={staggerItem}>
          <h3 className="text-[13px] font-medium text-[var(--color-text-tertiary)] mb-3 px-1">
            {month}
          </h3>
          <div className="grid grid-cols-3 gap-1.5">
            {monthEntries.map((entry) => (
              <TimelineEntry
                key={entry.id}
                entry={entry}
                onClick={() => onEntryClick?.(entry)}
              />
            ))}
          </div>
        </motion.div>
      ))}

      {/* Locked notice */}
      <div className="flex items-center justify-center gap-2 py-4">
        <Lock size={14} className="text-[var(--color-text-muted)]" />
        <span className="text-[12px] text-[var(--color-text-muted)]">
          Photos cannot be deleted
        </span>
      </div>
    </motion.div>
  );
}

function TimelineEntry({ entry, onClick }) {
  const confidenceColor = 
    entry.confidence >= 0.8 ? 'bg-[#22c55e]' :
    entry.confidence >= 0.5 ? 'bg-[#f59e0b]' :
    'bg-[#ef4444]';

  return (
    <motion.button
      whileTap={{ scale: 0.98 }}
      onClick={onClick}
      className="aspect-square relative bg-[var(--color-surface)] rounded-[8px] overflow-hidden"
    >
      {/* Placeholder for actual image */}
      <div className="absolute inset-0 flex items-center justify-center bg-[var(--color-surface-elevated)]">
        <Image size={20} className="text-[var(--color-text-muted)]" />
      </div>

      {/* Date overlay */}
      <div className="absolute bottom-0 left-0 right-0 p-1.5 bg-gradient-to-t from-black/70 to-transparent">
        <p className="text-[10px] text-white font-medium">
          {formatDay(entry.date)}
        </p>
      </div>

      {/* Confidence indicator */}
      <div className={`absolute top-1.5 right-1.5 w-2 h-2 rounded-full ${confidenceColor}`} />

      {/* Processing overlay */}
      {!entry.processed && (
        <div className="absolute inset-0 bg-black/40 flex items-center justify-center">
          <div className="w-1.5 h-1.5 rounded-full bg-white animate-pulse" />
        </div>
      )}
    </motion.button>
  );
}

function groupByMonth(entries) {
  const grouped = {};
  
  for (const entry of entries) {
    const date = new Date(entry.date);
    const key = date.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });
    
    if (!grouped[key]) {
      grouped[key] = [];
    }
    grouped[key].push(entry);
  }

  // Sort entries within each month by date (descending)
  for (const key of Object.keys(grouped)) {
    grouped[key].sort((a, b) => new Date(b.date) - new Date(a.date));
  }

  return grouped;
}

function formatDay(dateString) {
  const date = new Date(dateString);
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
}

export default Timeline;

