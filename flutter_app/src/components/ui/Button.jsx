import { motion } from 'framer-motion';
import { spring } from '../../utils/animations';

const variants = {
  primary: `
    bg-[var(--color-text-primary)] text-[var(--color-background)]
    hover:bg-[var(--color-text-secondary)]
  `,
  secondary: `
    bg-[var(--color-surface-elevated)] text-[var(--color-text-primary)]
    border border-[var(--color-border)]
    hover:bg-[var(--color-surface-hover)]
  `,
  ghost: `
    bg-transparent text-[var(--color-text-secondary)]
    hover:text-[var(--color-text-primary)]
    hover:bg-[var(--color-surface-elevated)]
  `,
  danger: `
    bg-[var(--color-error)] text-white
    hover:opacity-90
  `,
};

const sizes = {
  sm: 'h-8 px-3 text-[13px] rounded-[6px]',
  md: 'h-11 px-5 text-[15px] rounded-[8px]',
  lg: 'h-14 px-6 text-[17px] rounded-[12px]',
  full: 'h-14 px-6 text-[17px] rounded-[12px] w-full',
};

export function Button({
  children,
  variant = 'primary',
  size = 'md',
  disabled = false,
  loading = false,
  icon: Icon,
  iconPosition = 'left',
  className = '',
  onClick,
  ...props
}) {
  return (
    <motion.button
      whileTap={{ scale: disabled ? 1 : 0.98 }}
      transition={spring.snappy}
      disabled={disabled || loading}
      onClick={onClick}
      className={`
        inline-flex items-center justify-center gap-2
        font-medium select-none
        transition-colors duration-[150ms] ease-out
        disabled:opacity-40 disabled:cursor-not-allowed
        ${variants[variant]}
        ${sizes[size]}
        ${className}
      `}
      {...props}
    >
      {loading ? (
        <LoadingSpinner />
      ) : (
        <>
          {Icon && iconPosition === 'left' && <Icon size={18} strokeWidth={2} />}
          {children}
          {Icon && iconPosition === 'right' && <Icon size={18} strokeWidth={2} />}
        </>
      )}
    </motion.button>
  );
}

function LoadingSpinner() {
  return (
    <svg
      className="animate-spin h-5 w-5"
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
      viewBox="0 0 24 24"
    >
      <circle
        className="opacity-25"
        cx="12"
        cy="12"
        r="10"
        stroke="currentColor"
        strokeWidth="3"
      />
      <path
        className="opacity-75"
        fill="currentColor"
        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
      />
    </svg>
  );
}

export default Button;

