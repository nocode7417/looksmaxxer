import { motion } from 'framer-motion';
import { fadeUp } from '../../utils/animations';

const styles = {
  display: 'text-[36px] font-bold tracking-[-0.02em] leading-[1.1]',
  headline: 'text-[24px] font-semibold tracking-[-0.02em] leading-[1.2]',
  title: 'text-[20px] font-semibold leading-[1.2]',
  subtitle: 'text-[17px] font-medium leading-[1.3]',
  body: 'text-[15px] font-normal leading-[1.5]',
  caption: 'text-[13px] font-normal leading-[1.5] text-[var(--color-text-secondary)]',
  footnote: 'text-[11px] font-normal tracking-[0.02em] leading-[1.4] text-[var(--color-text-tertiary)]',
  label: 'text-[13px] font-medium uppercase tracking-[0.08em] text-[var(--color-text-tertiary)]',
};

const colors = {
  primary: 'text-[var(--color-text-primary)]',
  secondary: 'text-[var(--color-text-secondary)]',
  tertiary: 'text-[var(--color-text-tertiary)]',
  muted: 'text-[var(--color-text-muted)]',
  accent: 'text-[var(--color-accent)]',
  success: 'text-[var(--color-success)]',
  warning: 'text-[var(--color-warning)]',
  error: 'text-[var(--color-error)]',
};

export function Text({
  children,
  variant = 'body',
  color = 'primary',
  animate = false,
  delay = 0,
  as: Component = 'p',
  className = '',
  ...props
}) {
  const Wrapper = animate ? motion[Component] || motion.p : Component;
  
  const animationProps = animate
    ? {
        initial: fadeUp.initial,
        animate: fadeUp.animate,
        transition: { ...fadeUp.transition, delay },
      }
    : {};

  return (
    <Wrapper
      className={`${styles[variant]} ${colors[color]} ${className}`}
      {...animationProps}
      {...props}
    >
      {children}
    </Wrapper>
  );
}

export function Display({ children, className = '', ...props }) {
  return <Text variant="display" as="h1" className={className} {...props}>{children}</Text>;
}

export function Headline({ children, className = '', ...props }) {
  return <Text variant="headline" as="h2" className={className} {...props}>{children}</Text>;
}

export function Title({ children, className = '', ...props }) {
  return <Text variant="title" as="h3" className={className} {...props}>{children}</Text>;
}

export function Subtitle({ children, className = '', ...props }) {
  return <Text variant="subtitle" as="h4" className={className} {...props}>{children}</Text>;
}

export function Body({ children, className = '', ...props }) {
  return <Text variant="body" className={className} {...props}>{children}</Text>;
}

export function Caption({ children, className = '', ...props }) {
  return <Text variant="caption" color="secondary" className={className} {...props}>{children}</Text>;
}

export function Footnote({ children, className = '', ...props }) {
  return <Text variant="footnote" color="tertiary" className={className} {...props}>{children}</Text>;
}

export function Label({ children, className = '', ...props }) {
  return <Text variant="label" color="tertiary" as="span" className={className} {...props}>{children}</Text>;
}

export default Text;

