import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export function WelcomeScreen({ onComplete }) {
  const [phase, setPhase] = useState('message'); // 'message' | 'transition' | 'done'

  useEffect(() => {
    // Show message for 2.5 seconds, then transition
    const timer = setTimeout(() => {
      setPhase('transition');
    }, 2500);

    return () => clearTimeout(timer);
  }, []);

  useEffect(() => {
    if (phase === 'transition') {
      // Brief transition delay before moving to next screen
      const timer = setTimeout(() => {
        setPhase('done');
        onComplete?.();
      }, 600);

      return () => clearTimeout(timer);
    }
  }, [phase, onComplete]);

  return (
    <div className="min-h-full flex items-center justify-center bg-[var(--color-background)] px-8">
      <AnimatePresence mode="wait">
        {phase !== 'done' && (
          <motion.div
            key="welcome-message"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
            className="text-center"
          >
            <motion.p
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, delay: 0.3, ease: [0.16, 1, 0.3, 1] }}
              className="text-[20px] font-normal text-[var(--color-text-primary)] leading-relaxed tracking-[-0.01em]"
            >
              This is a measurement,
              <br />
              not a judgment.
            </motion.p>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

export default WelcomeScreen;

