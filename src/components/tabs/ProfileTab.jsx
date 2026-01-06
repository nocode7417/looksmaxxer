import { motion } from 'framer-motion';
import { User, Calendar, Camera, Flame, Settings, RotateCcw, ChevronRight, Info } from 'lucide-react';
import { Button } from '../ui/Button';
import { Card } from '../ui/Card';
import { staggerChildren, staggerItem } from '../../utils/animations';

export function ProfileTab({ state, progression, onResetApp }) {
  const { createdAt } = state;
  const { streakInfo, timelineStats, progressInfo } = progression;

  const daysSinceStart = createdAt 
    ? Math.floor((Date.now() - new Date(createdAt).getTime()) / (1000 * 60 * 60 * 24))
    : 0;

  return (
    <div className="px-6 pt-6 pb-8">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        className="mb-6"
      >
        <h1 className="text-[28px] font-semibold text-[var(--color-text-primary)] tracking-[-0.02em] mb-1">
          Profile
        </h1>
        <p className="text-[15px] text-[var(--color-text-secondary)]">
          Your tracking journey
        </p>
      </motion.div>

      <motion.div
        variants={staggerChildren}
        initial="initial"
        animate="animate"
        className="space-y-4"
      >
        {/* Stats overview */}
        <motion.div variants={staggerItem}>
          <Card variant="elevated" padding="none">
            <div className="grid grid-cols-2 divide-x divide-[var(--color-border-subtle)]">
              <StatItem
                icon={Calendar}
                label="Days tracking"
                value={daysSinceStart}
              />
              <StatItem
                icon={Camera}
                label="Total photos"
                value={timelineStats.totalPhotos}
              />
            </div>
            <div className="border-t border-[var(--color-border-subtle)] grid grid-cols-2 divide-x divide-[var(--color-border-subtle)]">
              <StatItem
                icon={Flame}
                label="Current streak"
                value={streakInfo.current}
              />
              <StatItem
                icon={User}
                label="Challenges done"
                value={state.challenges.length}
              />
            </div>
          </Card>
        </motion.div>

        {/* Journey info */}
        <motion.div variants={staggerItem}>
          <Card variant="default" padding="lg">
            <div className="flex items-center gap-3 mb-3">
              <Info size={18} className="text-[var(--color-text-tertiary)]" />
              <span className="text-[15px] font-medium text-[var(--color-text-primary)]">
                About Looksmaxxer
              </span>
            </div>
            <p className="text-[13px] text-[var(--color-text-secondary)] leading-relaxed">
              This app provides objective measurements, not judgments. 
              All metrics are designed to track consistency and potential, 
              never to assign beauty scores. Progress requires patience—meaningful 
              changes take weeks, not days.
            </p>
          </Card>
        </motion.div>

        {/* Settings section */}
        <motion.div variants={staggerItem}>
          <p className="text-[11px] font-medium uppercase tracking-[0.08em] text-[var(--color-text-tertiary)] mb-2 px-1">
            Settings
          </p>
          <Card variant="default" padding="none">
            <SettingsRow
              icon={Settings}
              label="Preferences"
              sublabel="Notifications, haptics"
              onClick={() => {}}
            />
            <div className="border-t border-[var(--color-border-subtle)]">
              <SettingsRow
                icon={RotateCcw}
                label="Reset app data"
                sublabel="Clear all photos and progress"
                onClick={onResetApp}
                destructive
              />
            </div>
          </Card>
        </motion.div>

        {/* Version info */}
        <motion.div variants={staggerItem}>
          <div className="text-center pt-4">
            <p className="text-[11px] text-[var(--color-text-muted)]">
              Looksmaxxer v1.0.0
            </p>
            <p className="text-[11px] text-[var(--color-text-muted)] mt-1">
              Built with precision and restraint
            </p>
          </div>
        </motion.div>
      </motion.div>
    </div>
  );
}

function StatItem({ icon: Icon, label, value }) {
  return (
    <div className="p-4 flex flex-col items-center">
      <Icon size={20} className="text-[var(--color-text-tertiary)] mb-2" />
      <p className="text-[24px] font-semibold text-[var(--color-text-primary)] mb-0.5">
        {value}
      </p>
      <p className="text-[11px] text-[var(--color-text-tertiary)]">
        {label}
      </p>
    </div>
  );
}

function SettingsRow({ icon: Icon, label, sublabel, onClick, destructive = false }) {
  return (
    <button
      onClick={onClick}
      className="w-full flex items-center gap-3 p-4 hover:bg-[var(--color-surface-hover)] transition-colors text-left"
    >
      <Icon 
        size={20} 
        className={destructive ? 'text-[var(--color-error)]' : 'text-[var(--color-text-tertiary)]'} 
      />
      <div className="flex-1">
        <p className={`text-[15px] font-medium ${
          destructive ? 'text-[var(--color-error)]' : 'text-[var(--color-text-primary)]'
        }`}>
          {label}
        </p>
        {sublabel && (
          <p className="text-[12px] text-[var(--color-text-tertiary)]">
            {sublabel}
          </p>
        )}
      </div>
      <ChevronRight size={18} className="text-[var(--color-text-muted)]" />
    </button>
  );
}

export default ProfileTab;

