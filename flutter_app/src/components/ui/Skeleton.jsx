export function Skeleton({ 
  className = '', 
  variant = 'rectangular',
  width,
  height,
}) {
  const variants = {
    rectangular: 'rounded-[8px]',
    circular: 'rounded-full',
    text: 'rounded-[4px]',
  };

  return (
    <div
      className={`
        animate-pulse 
        bg-[var(--color-surface-elevated)]
        ${variants[variant]}
        ${className}
      `}
      style={{ width, height }}
    />
  );
}

export function SkeletonCard({ className = '' }) {
  return (
    <div className={`p-4 rounded-[12px] bg-[var(--color-surface)] border border-[var(--color-border-subtle)] ${className}`}>
      <Skeleton className="h-4 w-24 mb-3" variant="text" />
      <Skeleton className="h-8 w-16 mb-2" variant="text" />
      <Skeleton className="h-3 w-full" variant="text" />
    </div>
  );
}

export function SkeletonMetric({ className = '' }) {
  return (
    <div className={`p-4 rounded-[12px] bg-[var(--color-surface)] border border-[var(--color-border-subtle)] ${className}`}>
      <div className="flex items-center gap-3 mb-4">
        <Skeleton className="w-10 h-10" variant="circular" />
        <div className="flex-1">
          <Skeleton className="h-4 w-24 mb-1" variant="text" />
          <Skeleton className="h-3 w-16" variant="text" />
        </div>
      </div>
      <Skeleton className="h-6 w-12 mb-3" variant="text" />
      <Skeleton className="h-2 w-full" variant="rectangular" />
    </div>
  );
}

export default Skeleton;

