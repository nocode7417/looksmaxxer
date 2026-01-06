// Utility helper functions

// Generate a unique ID
export function generateId() {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

// Format date for display
export function formatDate(date, options = {}) {
  const d = typeof date === 'string' ? new Date(date) : date;
  const defaultOptions = {
    month: 'long',
    day: 'numeric',
    year: 'numeric',
  };
  return d.toLocaleDateString('en-US', { ...defaultOptions, ...options });
}

// Format relative time
export function formatRelativeTime(date) {
  const d = typeof date === 'string' ? new Date(date) : date;
  const now = new Date();
  const diffMs = now - d;
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
  
  if (diffDays === 0) return 'Today';
  if (diffDays === 1) return 'Yesterday';
  if (diffDays < 7) return `${diffDays} days ago`;
  if (diffDays < 30) return `${Math.floor(diffDays / 7)} weeks ago`;
  if (diffDays < 365) return `${Math.floor(diffDays / 30)} months ago`;
  return `${Math.floor(diffDays / 365)} years ago`;
}

// Clamp a number between min and max
export function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

// Linear interpolation
export function lerp(start, end, t) {
  return start + (end - start) * t;
}

// Debounce function
export function debounce(fn, delay) {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
}

// Throttle function
export function throttle(fn, limit) {
  let inThrottle;
  return (...args) => {
    if (!inThrottle) {
      fn(...args);
      inThrottle = true;
      setTimeout(() => (inThrottle = false), limit);
    }
  };
}

// Deep clone object
export function deepClone(obj) {
  return JSON.parse(JSON.stringify(obj));
}

// Check if running on mobile device
export function isMobileDevice() {
  return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent
  );
}

// Sleep utility for async delays
export function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// Format number with commas
export function formatNumber(num) {
  return num.toLocaleString('en-US');
}

// Capitalize first letter
export function capitalizeFirst(str) {
  if (!str) return '';
  return str.charAt(0).toUpperCase() + str.slice(1);
}

// Truncate string with ellipsis
export function truncate(str, maxLength) {
  if (str.length <= maxLength) return str;
  return str.slice(0, maxLength - 3) + '...';
}

export default {
  generateId,
  formatDate,
  formatRelativeTime,
  clamp,
  lerp,
  debounce,
  throttle,
  deepClone,
  isMobileDevice,
  sleep,
  formatNumber,
  capitalizeFirst,
  truncate,
};

