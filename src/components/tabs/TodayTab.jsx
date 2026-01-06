import { motion } from 'framer-motion';
import { Camera, Check, Clock, Flame, Info } from 'lucide-react';
import { Button } from '../ui/Button';
import { Card, CardContent } from '../ui/Card';
import { staggerChildren, staggerItem } from '../../utils/animations';

export function TodayTab({ state, progression, onCapturePhoto, onCompleteChallenge }) {
  const {
    todaysChallenge,
    isTodayCompleted,
    streakInfo,
    progressInfo,
    daysRemaining,
    isProgressLocked,
  } = progression;

  return (
    <div className="px-6 pt-6 pb-8">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-6"
      >
        <p className="text-[11px] font-medium uppercase tracking-[0.08em] text-[var(--color-text-tertiary)] mb-1">
          {formatDate(new Date())}
        </p>
        <h1 className="text-[28px] font-semibold text-[var(--color-text-primary)] tracking-[-0.02em]">
          Today
        </h1>
      </motion.div>

      <motion.div
        variants={staggerChildren}
        initial="initial"
        animate="animate"
        className="space-y-4"
      >
        {/* Progress preview */}
        <motion.div variants={staggerItem}>
          <ProgressCard
            progressInfo={progressInfo}
            isLocked={isProgressLocked}
            daysRemaining={daysRemaining}
          />
        </motion.div>

        {/* Daily challenge */}
        {todaysChallenge && (
          <motion.div variants={staggerItem}>
            <ChallengeCard
              challenge={todaysChallenge}
              isCompleted={isTodayCompleted}
              onComplete={onCompleteChallenge}
              streakInfo={streakInfo}
            />
          </motion.div>
        )}

        {/* Photo capture */}
        <motion.div variants={staggerItem}>
          <CaptureCard onCapture={onCapturePhoto} />
        </motion.div>

        {/* Info note */}
        <motion.div variants={staggerItem}>
          <div className="flex items-start gap-3 p-4 bg-[var(--color-surface)] rounded-[12px] border border-[var(--color-border-subtle)]">
            <Info size={18} className="text-[var(--color-text-tertiary)] flex-shrink-0 mt-0.5" />
            <p className="text-[13px] text-[var(--color-text-secondary)] leading-relaxed">
              Progress updates are calculated every 7-14 days. 
              Consistent tracking improves measurement accuracy.
            </p>
          </div>
        </motion.div>
      </motion.div>
    </div>
  );
}

function ProgressCard({ progressInfo, isLocked, daysRemaining }) {
  if (isLocked) {
    return (
      <Card variant="elevated" padding="lg">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <Clock size={18} className="text-[var(--color-text-tertiary)]" />
            <span className="text-[13px] font-medium text-[var(--color-text-secondary)]">
              Progress Score
            </span>
          </div>
          <span className="text-[11px] px-2 py-1 bg-[var(--color-surface)] rounded-full text-[var(--color-text-tertiary)]">
            Locked
          </span>
        </div>
        
        <div className="mb-3">
          <div className="flex items-baseline gap-2">
            <span className="text-[32px] font-bold text-[var(--color-text-muted)]">
              --
            </span>
          </div>
        </div>

        {/* Progress bar */}
        <div className="w-full h-1.5 bg-[var(--color-surface)] rounded-full overflow-hidden mb-2">
          <motion.div
            className="h-full bg-[var(--color-text-tertiary)]"
            initial={{ width: 0 }}
            animate={{ width: `${progressInfo.unlockProgress * 100}%` }}
            transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
          />
        </div>

        <p className="text-[11px] text-[var(--color-text-muted)]">
          {daysRemaining > 0 
            ? `Unlocks in ${daysRemaining} days with consistent tracking`
            : 'Keep tracking to unlock your score'
          }
        </p>
      </Card>
    );
  }

  return (
    <Card variant="elevated" padding="lg">
      <div className="flex items-center justify-between mb-3">
        <span className="text-[13px] font-medium text-[var(--color-text-secondary)]">
          Progress Score
        </span>
        <span className={`text-[11px] px-2 py-1 rounded-full ${
          progressInfo.trend === 'improving' 
            ? 'bg-[#22c55e]/20 text-[#22c55e]'
            : progressInfo.trend === 'declining'
            ? 'bg-[#ef4444]/20 text-[#ef4444]'
            : 'bg-[var(--color-surface)] text-[var(--color-text-tertiary)]'
        }`}>
          {progressInfo.trend === 'improving' ? 'Improving' : 
           progressInfo.trend === 'declining' ? 'Declining' : 'Stable'}
        </span>
      </div>
      
      <div className="flex items-baseline gap-2">
        <span className="text-[40px] font-bold text-[var(--color-text-primary)] tracking-[-0.02em]">
          {progressInfo.score}
        </span>
        <span className="text-[15px] text-[var(--color-text-tertiary)]">/ 100</span>
      </div>
    </Card>
  );
}

function ChallengeCard({ challenge, isCompleted, onComplete, streakInfo }) {
  const categoryColors = {
    hydration: '#3b82f6',
    sleep: '#8b5cf6',
    posture: '#10b981',
    skincare: '#f59e0b',
    nutrition: '#ef4444',
  };

  const color = categoryColors[challenge.category?.id] || '#6b7280';

  return (
    <Card variant="default" padding="none">
      {/* Header */}
      <div className="p-4 border-b border-[var(--color-border-subtle)]">
        <div className="flex items-center justify-between mb-2">
          <div className="flex items-center gap-2">
            <div 
              className="w-2 h-2 rounded-full"
              style={{ backgroundColor: color }}
            />
            <span className="text-[11px] font-medium uppercase tracking-[0.08em] text-[var(--color-text-tertiary)]">
              Daily Experiment
            </span>
          </div>
          
          {streakInfo.current > 0 && (
            <div className="flex items-center gap-1">
              <Flame size={14} className="text-[#f59e0b]" />
              <span className="text-[11px] font-medium text-[#f59e0b]">
                {streakInfo.current}
              </span>
            </div>
          )}
        </div>
        
        <h3 className="text-[17px] font-semibold text-[var(--color-text-primary)] mb-1">
          {challenge.title}
        </h3>
        <p className="text-[15px] text-[var(--color-text-secondary)]">
          {challenge.description}
        </p>
      </div>

      {/* Rationale */}
      <div className="px-4 py-3 bg-[var(--color-surface-elevated)]">
        <p className="text-[12px] text-[var(--color-text-tertiary)] leading-relaxed">
          <span className="font-medium">Why: </span>
          {challenge.rationale}
        </p>
      </div>

      {/* Action */}
      <div className="p-4">
        {isCompleted ? (
          <div className="flex items-center gap-2 text-[var(--color-success)]">
            <Check size={18} />
            <span className="text-[15px] font-medium">Completed</span>
          </div>
        ) : (
          <Button
            variant="secondary"
            size="md"
            onClick={onComplete}
            className="w-full"
          >
            Mark as Completed
          </Button>
        )}
      </div>
    </Card>
  );
}

function CaptureCard({ onCapture }) {
  return (
    <Card 
      variant="interactive" 
      padding="lg"
      onClick={onCapture}
    >
      <div className="flex items-center gap-4">
        <div className="w-12 h-12 rounded-[12px] bg-[var(--color-surface-elevated)] flex items-center justify-center">
          <Camera size={24} strokeWidth={1.5} className="text-[var(--color-text-secondary)]" />
        </div>
        <div className="flex-1">
          <h3 className="text-[15px] font-medium text-[var(--color-text-primary)] mb-0.5">
            Capture today's data
          </h3>
          <p className="text-[13px] text-[var(--color-text-tertiary)]">
            Optional daily photo for timeline
          </p>
        </div>
      </div>
    </Card>
  );
}

function formatDate(date) {
  return date.toLocaleDateString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
  });
}

export default TodayTab;

