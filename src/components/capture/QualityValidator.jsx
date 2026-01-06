import { motion } from 'framer-motion';
import { Check, AlertCircle, Loader2 } from 'lucide-react';

export function QualityValidator({ quality, isAnalyzing }) {
  if (isAnalyzing) {
    return (
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        className="bg-black/60 backdrop-blur-md rounded-[12px] p-4"
      >
        <div className="flex items-center gap-3">
          <Loader2 size={20} className="text-white animate-spin" />
          <span className="text-[15px] text-white font-medium">
            Analyzing capture quality...
          </span>
        </div>
      </motion.div>
    );
  }

  if (!quality) return null;

  const isAcceptable = quality.isAcceptable;

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      className={`rounded-[12px] p-4 ${
        isAcceptable 
          ? 'bg-[#22c55e]/20 backdrop-blur-md' 
          : 'bg-[#ef4444]/20 backdrop-blur-md'
      }`}
    >
      <div className="flex items-start gap-3">
        {/* Status icon */}
        <div className={`flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center ${
          isAcceptable ? 'bg-[#22c55e]/30' : 'bg-[#ef4444]/30'
        }`}>
          {isAcceptable ? (
            <Check size={18} className="text-[#22c55e]" />
          ) : (
            <AlertCircle size={18} className="text-[#ef4444]" />
          )}
        </div>

        {/* Content */}
        <div className="flex-1">
          <p className={`text-[15px] font-medium mb-1 ${
            isAcceptable ? 'text-[#22c55e]' : 'text-[#ef4444]'
          }`}>
            {isAcceptable ? 'Good quality capture' : 'Quality issues detected'}
          </p>
          <p className="text-[13px] text-white/70">
            {quality.feedback}
          </p>

          {/* Quality metrics */}
          <div className="flex gap-4 mt-3">
            <QualityMetric label="Brightness" value={quality.brightness} />
            <QualityMetric label="Sharpness" value={quality.sharpness} />
            <QualityMetric label="Contrast" value={quality.contrast} />
          </div>
        </div>
      </div>
    </motion.div>
  );
}

function QualityMetric({ label, value }) {
  const getColor = (val) => {
    if (val >= 70) return 'text-[#22c55e]';
    if (val >= 50) return 'text-[#f59e0b]';
    return 'text-[#ef4444]';
  };

  return (
    <div className="flex flex-col items-center">
      <span className={`text-[15px] font-semibold ${getColor(value)}`}>
        {value}
      </span>
      <span className="text-[11px] text-white/50">
        {label}
      </span>
    </div>
  );
}

export default QualityValidator;

