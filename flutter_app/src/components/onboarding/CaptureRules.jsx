import { motion } from 'framer-motion';
import { Sun, Maximize2, Meh, Sparkles } from 'lucide-react';
import { Button } from '../ui/Button';
import { staggerChildren, staggerItem } from '../../utils/animations';

const CAPTURE_RULES = [
  {
    icon: Sun,
    title: 'Neutral lighting',
    description: 'Face a window or use soft, even light',
    rationale: 'Reduces shadow variance that distorts measurements',
  },
  {
    icon: Maximize2,
    title: 'Direct angle',
    description: 'Camera at eye level, face centered',
    rationale: 'Minimizes perspective distortion of facial proportions',
  },
  {
    icon: Meh,
    title: 'Neutral expression',
    description: 'Relaxed face, lips gently closed',
    rationale: 'Establishes baseline muscle state for consistency',
  },
  {
    icon: Sparkles,
    title: 'No filters',
    description: 'Use your device camera directly',
    rationale: 'Preserves texture data required for accurate analysis',
  },
];

export function CaptureRules({ onBeginCapture }) {
  return (
    <div className="min-h-full flex flex-col bg-[var(--color-background)] px-6 pt-8 pb-8">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
        className="mb-8"
      >
        <h1 className="text-[24px] font-semibold text-[var(--color-text-primary)] tracking-[-0.02em] mb-2">
          Capture requirements
        </h1>
        <p className="text-[15px] text-[var(--color-text-secondary)] leading-relaxed">
          Each constraint exists for a reason.
        </p>
      </motion.div>

      {/* Rules list */}
      <motion.div
        variants={staggerChildren}
        initial="initial"
        animate="animate"
        className="flex-1 space-y-4"
      >
        {CAPTURE_RULES.map((rule, index) => (
          <RuleCard key={rule.title} rule={rule} index={index} />
        ))}
      </motion.div>

      {/* CTA */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.6, ease: [0.16, 1, 0.3, 1] }}
        className="mt-8"
      >
        <Button size="full" onClick={onBeginCapture}>
          Begin Capture
        </Button>
      </motion.div>
    </div>
  );
}

function RuleCard({ rule, index }) {
  const Icon = rule.icon;

  return (
    <motion.div
      variants={staggerItem}
      className="bg-[var(--color-surface)] border border-[var(--color-border-subtle)] rounded-[12px] p-4"
    >
      <div className="flex gap-4">
        {/* Icon */}
        <div className="flex-shrink-0 w-10 h-10 rounded-[10px] bg-[var(--color-surface-elevated)] flex items-center justify-center">
          <Icon size={20} strokeWidth={1.5} className="text-[var(--color-text-secondary)]" />
        </div>

        {/* Content */}
        <div className="flex-1 min-w-0">
          <h3 className="text-[15px] font-medium text-[var(--color-text-primary)] mb-0.5">
            {rule.title}
          </h3>
          <p className="text-[13px] text-[var(--color-text-secondary)] mb-2">
            {rule.description}
          </p>
          <p className="text-[11px] text-[var(--color-text-tertiary)] leading-relaxed">
            {rule.rationale}
          </p>
        </div>
      </div>
    </motion.div>
  );
}

export default CaptureRules;

