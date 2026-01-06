import { motion } from 'framer-motion';

// iPhone 15 Pro dimensions (logical pixels)
const DEVICE_CONFIG = {
  iphone: {
    width: 393,
    height: 852,
    borderRadius: 55,
    notchHeight: 34,
    homeIndicatorHeight: 5,
    bezelWidth: 12,
  },
};

export function DeviceFrame({ children, device = 'iphone' }) {
  const config = DEVICE_CONFIG[device];
  
  return (
    <div className="device-container min-h-screen flex items-center justify-center p-6 bg-[#030303]">
      {/* Outer device shell */}
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
        className="relative"
        style={{
          width: config.width + config.bezelWidth * 2,
          height: config.height + config.bezelWidth * 2,
        }}
      >
        {/* Device bezel */}
        <div
          className="absolute inset-0 bg-[#1a1a1a] shadow-2xl"
          style={{
            borderRadius: config.borderRadius + config.bezelWidth / 2,
            boxShadow: `
              0 0 0 1px rgba(255,255,255,0.1),
              0 25px 50px -12px rgba(0,0,0,0.8),
              0 0 80px -20px rgba(0,0,0,0.5)
            `,
          }}
        />
        
        {/* Side buttons - Volume */}
        <div
          className="absolute bg-[#2a2a2a] rounded-l-[2px]"
          style={{
            left: -2,
            top: 150,
            width: 3,
            height: 30,
          }}
        />
        <div
          className="absolute bg-[#2a2a2a] rounded-l-[2px]"
          style={{
            left: -2,
            top: 190,
            width: 3,
            height: 60,
          }}
        />
        <div
          className="absolute bg-[#2a2a2a] rounded-l-[2px]"
          style={{
            left: -2,
            top: 260,
            width: 3,
            height: 60,
          }}
        />
        
        {/* Side button - Power */}
        <div
          className="absolute bg-[#2a2a2a] rounded-r-[2px]"
          style={{
            right: -2,
            top: 200,
            width: 3,
            height: 80,
          }}
        />

        {/* Screen area */}
        <div
          className="absolute overflow-hidden bg-[var(--color-background)]"
          style={{
            top: config.bezelWidth,
            left: config.bezelWidth,
            right: config.bezelWidth,
            bottom: config.bezelWidth,
            borderRadius: config.borderRadius,
          }}
        >
          {/* Dynamic Island */}
          <div className="absolute top-0 left-0 right-0 z-50 flex justify-center pt-[11px] pointer-events-none">
            <div
              className="bg-black rounded-full"
              style={{
                width: 126,
                height: config.notchHeight,
                borderRadius: 17,
              }}
            />
          </div>

          {/* App content */}
          <div className="relative w-full h-full overflow-auto">
            {children}
          </div>

          {/* Home indicator */}
          <div className="absolute bottom-0 left-0 right-0 z-50 flex justify-center pb-2 pointer-events-none">
            <div
              className="bg-white/30 rounded-full"
              style={{
                width: 134,
                height: config.homeIndicatorHeight,
              }}
            />
          </div>
        </div>

        {/* Screen reflection effect */}
        <div
          className="absolute pointer-events-none opacity-[0.02]"
          style={{
            top: config.bezelWidth,
            left: config.bezelWidth,
            right: config.bezelWidth,
            bottom: config.bezelWidth,
            borderRadius: config.borderRadius,
            background: 'linear-gradient(135deg, white 0%, transparent 50%)',
          }}
        />
      </motion.div>
    </div>
  );
}

// Safe area wrapper for content
export function SafeArea({ children, className = '' }) {
  return (
    <div 
      className={`pt-[59px] pb-[34px] min-h-full ${className}`}
    >
      {children}
    </div>
  );
}

// Screen wrapper with safe areas built in
export function Screen({ children, className = '' }) {
  return (
    <div className={`min-h-full bg-[var(--color-background)] ${className}`}>
      <SafeArea>
        {children}
      </SafeArea>
    </div>
  );
}

export default DeviceFrame;

