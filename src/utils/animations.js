// Framer Motion animation presets
// Physics-based, subtle, Apple-esque

export const spring = {
  gentle: {
    type: "spring",
    stiffness: 300,
    damping: 30,
  },
  snappy: {
    type: "spring",
    stiffness: 400,
    damping: 35,
  },
  soft: {
    type: "spring",
    stiffness: 200,
    damping: 25,
  },
};

export const fade = {
  initial: { opacity: 0 },
  animate: { opacity: 1 },
  exit: { opacity: 0 },
  transition: { duration: 0.4, ease: [0.16, 1, 0.3, 1] },
};

export const fadeUp = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: -10 },
  transition: { duration: 0.4, ease: [0.16, 1, 0.3, 1] },
};

export const fadeScale = {
  initial: { opacity: 0, scale: 0.98 },
  animate: { opacity: 1, scale: 1 },
  exit: { opacity: 0, scale: 0.98 },
  transition: { duration: 0.4, ease: [0.16, 1, 0.3, 1] },
};

export const slideUp = {
  initial: { y: "100%" },
  animate: { y: 0 },
  exit: { y: "100%" },
  transition: spring.gentle,
};

export const slideRight = {
  initial: { x: "100%", opacity: 0 },
  animate: { x: 0, opacity: 1 },
  exit: { x: "-20%", opacity: 0 },
  transition: { duration: 0.35, ease: [0.16, 1, 0.3, 1] },
};

export const scalePress = {
  whileTap: { scale: 0.98 },
  transition: spring.snappy,
};

export const staggerChildren = {
  animate: {
    transition: {
      staggerChildren: 0.08,
      delayChildren: 0.1,
    },
  },
};

export const staggerItem = {
  initial: { opacity: 0, y: 16 },
  animate: { opacity: 1, y: 0 },
  transition: { duration: 0.4, ease: [0.16, 1, 0.3, 1] },
};

// Page transition variants
export const pageVariants = {
  initial: { opacity: 0, x: 20 },
  animate: { opacity: 1, x: 0 },
  exit: { opacity: 0, x: -20 },
};

export const pageTransition = {
  duration: 0.35,
  ease: [0.16, 1, 0.3, 1],
};

// Delay utility
export const withDelay = (variants, delay) => ({
  ...variants,
  transition: {
    ...variants.transition,
    delay,
  },
});

