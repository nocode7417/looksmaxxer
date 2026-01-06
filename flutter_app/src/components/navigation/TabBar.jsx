import { motion } from 'framer-motion';
import { Home, CalendarDays, BarChart3, User } from 'lucide-react';

const TAB_CONFIG = {
  today: {
    icon: Home,
    label: 'Today',
  },
  timeline: {
    icon: CalendarDays,
    label: 'Timeline',
  },
  baseline: {
    icon: BarChart3,
    label: 'Baseline',
  },
  profile: {
    icon: User,
    label: 'Profile',
  },
};

export function TabBar({ tabs, activeTab, onTabChange }) {
  return (
    <div className="fixed bottom-0 left-0 right-0 z-50">
      {/* Background blur */}
      <div className="absolute inset-0 bg-[var(--color-background)]/80 backdrop-blur-xl border-t border-[var(--color-border-subtle)]" />
      
      {/* Tab items */}
      <div className="relative flex items-center justify-around px-4 pb-8 pt-2">
        {tabs.map((tabId) => {
          const tab = TAB_CONFIG[tabId];
          const Icon = tab.icon;
          const isActive = activeTab === tabId;

          return (
            <motion.button
              key={tabId}
              onClick={() => onTabChange(tabId)}
              whileTap={{ scale: 0.95 }}
              className="flex flex-col items-center gap-1 py-1 px-4 min-w-[64px]"
            >
              <div className="relative">
                <Icon
                  size={24}
                  strokeWidth={isActive ? 2 : 1.5}
                  className={`transition-colors duration-150 ${
                    isActive
                      ? 'text-[var(--color-text-primary)]'
                      : 'text-[var(--color-text-tertiary)]'
                  }`}
                />
                
                {/* Active indicator dot */}
                {isActive && (
                  <motion.div
                    layoutId="activeIndicator"
                    className="absolute -bottom-1 left-1/2 w-1 h-1 bg-[var(--color-text-primary)] rounded-full"
                    style={{ transform: 'translateX(-50%)' }}
                  />
                )}
              </div>
              
              <span
                className={`text-[10px] font-medium transition-colors duration-150 ${
                  isActive
                    ? 'text-[var(--color-text-primary)]'
                    : 'text-[var(--color-text-tertiary)]'
                }`}
              >
                {tab.label}
              </span>
            </motion.button>
          );
        })}
      </div>
    </div>
  );
}

export default TabBar;

