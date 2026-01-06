import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { TabBar } from './navigation/TabBar';
import { TodayTab } from './tabs/TodayTab';
import { TimelineTab } from './tabs/TimelineTab';
import { BaselineTab } from './tabs/BaselineTab';
import { ProfileTab } from './tabs/ProfileTab';

const TABS = ['today', 'timeline', 'baseline', 'profile'];

export function Dashboard({ 
  state, 
  progression, 
  onCapturePhoto, 
  onCompleteChallenge,
  onResetApp 
}) {
  const [activeTab, setActiveTab] = useState('today');

  const renderTab = () => {
    switch (activeTab) {
      case 'today':
        return (
          <TodayTab
            state={state}
            progression={progression}
            onCapturePhoto={onCapturePhoto}
            onCompleteChallenge={onCompleteChallenge}
          />
        );
      case 'timeline':
        return (
          <TimelineTab
            timeline={state.timeline}
            stats={progression.timelineStats}
          />
        );
      case 'baseline':
        return (
          <BaselineTab
            metrics={state.metrics}
            baselineDate={state.baselineDate}
            progression={progression}
          />
        );
      case 'profile':
        return (
          <ProfileTab
            state={state}
            progression={progression}
            onResetApp={onResetApp}
          />
        );
      default:
        return null;
    }
  };

  return (
    <div className="min-h-full flex flex-col bg-[var(--color-background)]">
      {/* Content area */}
      <div className="flex-1 overflow-auto pb-20">
        <AnimatePresence mode="wait">
          <motion.div
            key={activeTab}
            initial={{ opacity: 0, x: 10 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -10 }}
            transition={{ duration: 0.2 }}
            className="min-h-full"
          >
            {renderTab()}
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Tab bar */}
      <TabBar
        tabs={TABS}
        activeTab={activeTab}
        onTabChange={setActiveTab}
      />
    </div>
  );
}

export default Dashboard;

