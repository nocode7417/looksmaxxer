import { motion } from 'framer-motion';
import { fadeUp } from '../../utils/animations';

const variants = {
  default: `
    bg-[var(--color-surface)]
    border border-[var(--color-border-subtle)]
  `,
  elevated: `
    bg-[var(--color-surface-elevated)]
    border border-[var(--color-border)]
  `,
  ghost: `
    bg-transparent
  `,
  interactive: `
    bg-[var(--color-surface)]
    border border-[var(--color-border-subtle)]
    hover:bg-[var(--color-surface-elevated)]
    hover:border-[var(--color-border)]
    cursor-pointer
    transition-colors duration-[150ms]
  `,
};

const paddings = {
  none: '',
  sm: 'p-3',
  md: 'p-4',
  lg: 'p-6',
};

export function Card({
  children,
  variant = 'default',
  padding = 'md',
  rounded = 'lg',
  animate = false,
  delay = 0,
  className = '',
  onClick,
  ...props
}) {
  const roundedClasses = {
    md: 'rounded-[8px]',
    lg: 'rounded-[12px]',
    xl: 'rounded-[16px]',
  };

  const Component = animate ? motion.div : 'div';
  const animationProps = animate
    ? {
        initial: fadeUp.initial,
        animate: fadeUp.animate,
        transition: { ...fadeUp.transition, delay },
      }
    : {};

  return (
    <Component
      onClick={onClick}
      className={`
        ${variants[variant]}
        ${paddings[padding]}
        ${roundedClasses[rounded]}
        ${className}
      `}
      {...animationProps}
      {...props}
    >
      {children}
    </Component>
  );
}

export function CardHeader({ children, className = '' }) {
  return (
    <div className={`mb-3 ${className}`}>
      {children}
    </div>
  );
}

export function CardTitle({ children, className = '' }) {
  return (
    <h3 className={`text-[17px] font-semibold text-[var(--color-text-primary)] ${className}`}>
      {children}
    </h3>
  );
}

export function CardDescription({ children, className = '' }) {
  return (
    <p className={`text-[13px] text-[var(--color-text-secondary)] mt-1 ${className}`}>
      {children}
    </p>
  );
}

export function CardContent({ children, className = '' }) {
  return (
    <div className={className}>
      {children}
    </div>
  );
}

export function CardFooter({ children, className = '' }) {
  return (
    <div className={`mt-4 pt-4 border-t border-[var(--color-border-subtle)] ${className}`}>
      {children}
    </div>
  );
}

export default Card;

