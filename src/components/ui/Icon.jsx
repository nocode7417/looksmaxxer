import * as LucideIcons from 'lucide-react';

// Icon wrapper for consistent sizing and styling
export function Icon({ 
  name, 
  size = 20, 
  strokeWidth = 1.5,
  className = '',
  ...props 
}) {
  const IconComponent = LucideIcons[name];
  
  if (!IconComponent) {
    console.warn(`Icon "${name}" not found in Lucide icons`);
    return null;
  }

  return (
    <IconComponent
      size={size}
      strokeWidth={strokeWidth}
      className={`text-current ${className}`}
      {...props}
    />
  );
}

// Pre-configured icons for the app
export const Icons = {
  // Navigation
  Home: (props) => <Icon name="Home" {...props} />,
  Timeline: (props) => <Icon name="CalendarDays" {...props} />,
  Chart: (props) => <Icon name="BarChart3" {...props} />,
  User: (props) => <Icon name="User" {...props} />,
  Settings: (props) => <Icon name="Settings" {...props} />,
  
  // Actions
  Camera: (props) => <Icon name="Camera" {...props} />,
  Check: (props) => <Icon name="Check" {...props} />,
  X: (props) => <Icon name="X" {...props} />,
  ChevronRight: (props) => <Icon name="ChevronRight" {...props} />,
  ChevronLeft: (props) => <Icon name="ChevronLeft" {...props} />,
  ChevronDown: (props) => <Icon name="ChevronDown" {...props} />,
  Plus: (props) => <Icon name="Plus" {...props} />,
  Refresh: (props) => <Icon name="RefreshCw" {...props} />,
  
  // Analysis metrics
  Symmetry: (props) => <Icon name="Shapes" {...props} />,
  Proportions: (props) => <Icon name="Ruler" {...props} />,
  Skin: (props) => <Icon name="Sparkles" {...props} />,
  Eye: (props) => <Icon name="Eye" {...props} />,
  Structure: (props) => <Icon name="Box" {...props} />,
  
  // Challenges
  Droplets: (props) => <Icon name="Droplets" {...props} />,
  Moon: (props) => <Icon name="Moon" {...props} />,
  Activity: (props) => <Icon name="Activity" {...props} />,
  Heart: (props) => <Icon name="Heart" {...props} />,
  
  // Status
  Info: (props) => <Icon name="Info" {...props} />,
  AlertCircle: (props) => <Icon name="AlertCircle" {...props} />,
  CheckCircle: (props) => <Icon name="CheckCircle" {...props} />,
  Lock: (props) => <Icon name="Lock" {...props} />,
  Unlock: (props) => <Icon name="Unlock" {...props} />,
  
  // Misc
  Zap: (props) => <Icon name="Zap" {...props} />,
  Target: (props) => <Icon name="Target" {...props} />,
  TrendingUp: (props) => <Icon name="TrendingUp" {...props} />,
  Clock: (props) => <Icon name="Clock" {...props} />,
  Calendar: (props) => <Icon name="Calendar" {...props} />,
};

export default Icon;

