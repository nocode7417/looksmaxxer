import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Button } from '../ui/Button';
import { MetricCard } from './MetricCard';
import { staggerChildren, staggerItem } from '../../utils/animations';
import { analyzePhoto, getMetricDefinitions } from '../../engine/analysis';

export function ReportScreen({ photoData, onContinue }) {
  const [isAnalyzing, setIsAnalyzing] = useState(true);
  const [analysisResult, setAnalysisResult] = useState(null);

  useEffect(() => {
    async function runAnalysis() {
      setIsAnalyzing(true);
      try {
        const result = await analyzePhoto(photoData);
        setAnalysisResult(result);
      } catch (error) {
        console.error('Analysis error:', error);
      }
      setIsAnalyzing(false);
    }

    if (photoData) {
      runAnalysis();
    }
  }, [photoData]);

  if (isAnalyzing) {
    return <AnalyzingState />;
  }

  if (!analysisResult) {
    return (
      <div className="min-h-full flex items-center justify-center p-6">
        <p className="text-[var(--color-text-secondary)]">Analysis failed. Please try again.</p>
      </div>
    );
  }

  const { metrics, analyzedAt, overallConfidence } = analysisResult;
  const metricEntries = Object.entries(metrics);

  return (
    <div className="min-h-full flex flex-col bg-[var(--color-background)]">
      {/* Header */}
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
        className="px-6 pt-6 pb-4"
      >
        <p className="text-[11px] font-medium uppercase tracking-[0.08em] text-[var(--color-text-tertiary)] mb-1">
          Your Baseline
        </p>
        <h1 className="text-[24px] font-semibold text-[var(--color-text-primary)] tracking-[-0.02em]">
          Initial Analysis
        </h1>
        <p className="text-[13px] text-[var(--color-text-secondary)] mt-1">
          Measured {formatDate(analyzedAt)} · {capitalizeFirst(overallConfidence)} confidence
        </p>
      </motion.div>

      {/* Metrics list */}
      <motion.div
        variants={staggerChildren}
        initial="initial"
        animate="animate"
        className="flex-1 px-6 pb-6 space-y-3 overflow-auto"
      >
        {metricEntries.map(([key, metric], index) => (
          <motion.div key={key} variants={staggerItem}>
            <MetricCard metricKey={key} metric={metric} />
          </motion.div>
        ))}

        {/* Disclaimer */}
        <motion.div
          variants={staggerItem}
          className="pt-4"
        >
          <p className="text-[11px] text-[var(--color-text-muted)] leading-relaxed text-center">
            These measurements represent your current baseline.
            <br />
            Accuracy improves with consistent tracking over time.
          </p>
        </motion.div>
      </motion.div>

      {/* Footer */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.8, ease: [0.16, 1, 0.3, 1] }}
        className="px-6 pb-6 pt-2 border-t border-[var(--color-border-subtle)]"
      >
        <p className="text-[13px] text-[var(--color-text-secondary)] text-center mb-4">
          This is your starting point.
        </p>
        <Button size="full" onClick={onContinue}>
          Continue
        </Button>
      </motion.div>
    </div>
  );
}

function AnalyzingState() {
  return (
    <div className="min-h-full flex flex-col items-center justify-center bg-[var(--color-background)] px-6">
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="text-center"
      >
        {/* Animated scanner */}
        <div className="relative w-32 h-32 mx-auto mb-8">
          <motion.div
            className="absolute inset-0 border-2 border-[var(--color-border)] rounded-[16px]"
            initial={{ opacity: 0.5 }}
            animate={{ opacity: [0.5, 1, 0.5] }}
            transition={{ duration: 2, repeat: Infinity }}
          />
          <motion.div
            className="absolute left-0 right-0 h-0.5 bg-[var(--color-text-primary)]"
            initial={{ top: '10%' }}
            animate={{ top: ['10%', '90%', '10%'] }}
            transition={{ duration: 2.5, repeat: Infinity, ease: 'linear' }}
          />
        </div>

        <h2 className="text-[17px] font-semibold text-[var(--color-text-primary)] mb-2">
          Analyzing your baseline
        </h2>
        <p className="text-[15px] text-[var(--color-text-secondary)]">
          This takes a few moments...
        </p>

        {/* Processing steps */}
        <div className="mt-8 space-y-2">
          <ProcessingStep label="Mapping facial landmarks" delay={0} />
          <ProcessingStep label="Calculating symmetry" delay={0.5} />
          <ProcessingStep label="Analyzing proportions" delay={1} />
          <ProcessingStep label="Evaluating skin texture" delay={1.5} />
        </div>
      </motion.div>
    </div>
  );
}

function ProcessingStep({ label, delay }) {
  return (
    <motion.div
      initial={{ opacity: 0, x: -10 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay, duration: 0.4 }}
      className="flex items-center gap-2 justify-center"
    >
      <motion.div
        className="w-1.5 h-1.5 rounded-full bg-[var(--color-text-tertiary)]"
        animate={{ opacity: [0.3, 1, 0.3] }}
        transition={{ duration: 1.5, repeat: Infinity, delay }}
      />
      <span className="text-[13px] text-[var(--color-text-tertiary)]">{label}</span>
    </motion.div>
  );
}

function formatDate(isoString) {
  const date = new Date(isoString);
  return date.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });
}

function capitalizeFirst(str) {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

export default ReportScreen;

