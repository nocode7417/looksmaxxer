// Image processing utilities

// Convert base64 to blob
export function base64ToBlob(base64, mimeType = 'image/jpeg') {
  const byteString = atob(base64.split(',')[1]);
  const ab = new ArrayBuffer(byteString.length);
  const ia = new Uint8Array(ab);
  
  for (let i = 0; i < byteString.length; i++) {
    ia[i] = byteString.charCodeAt(i);
  }
  
  return new Blob([ab], { type: mimeType });
}

// Convert blob to base64
export function blobToBase64(blob) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onloadend = () => resolve(reader.result);
    reader.onerror = reject;
    reader.readAsDataURL(blob);
  });
}

// Resize image to max dimensions
export function resizeImage(imageData, maxWidth = 1080, maxHeight = 1920, quality = 0.85) {
  return new Promise((resolve) => {
    const img = new Image();
    img.onload = () => {
      let { width, height } = img;
      
      // Calculate new dimensions
      if (width > maxWidth || height > maxHeight) {
        const ratio = Math.min(maxWidth / width, maxHeight / height);
        width = Math.round(width * ratio);
        height = Math.round(height * ratio);
      }
      
      // Draw to canvas
      const canvas = document.createElement('canvas');
      canvas.width = width;
      canvas.height = height;
      
      const ctx = canvas.getContext('2d');
      ctx.drawImage(img, 0, 0, width, height);
      
      resolve(canvas.toDataURL('image/jpeg', quality));
    };
    img.src = imageData;
  });
}

// Calculate image brightness
export function calculateBrightness(imageData) {
  return new Promise((resolve) => {
    const img = new Image();
    img.onload = () => {
      const canvas = document.createElement('canvas');
      const size = 100; // Sample at low res for speed
      canvas.width = size;
      canvas.height = size;
      
      const ctx = canvas.getContext('2d');
      ctx.drawImage(img, 0, 0, size, size);
      
      const data = ctx.getImageData(0, 0, size, size).data;
      let totalBrightness = 0;
      
      for (let i = 0; i < data.length; i += 4) {
        // Luminance formula
        totalBrightness += (0.299 * data[i] + 0.587 * data[i + 1] + 0.114 * data[i + 2]);
      }
      
      const avgBrightness = totalBrightness / (data.length / 4);
      resolve(Math.round((avgBrightness / 255) * 100));
    };
    img.src = imageData;
  });
}

// Calculate image sharpness (Laplacian variance)
export function calculateSharpness(imageData) {
  return new Promise((resolve) => {
    const img = new Image();
    img.onload = () => {
      const canvas = document.createElement('canvas');
      const size = 200;
      canvas.width = size;
      canvas.height = size;
      
      const ctx = canvas.getContext('2d');
      ctx.drawImage(img, 0, 0, size, size);
      
      const data = ctx.getImageData(0, 0, size, size).data;
      
      // Convert to grayscale and calculate Laplacian variance
      const gray = [];
      for (let i = 0; i < data.length; i += 4) {
        gray.push((data[i] + data[i + 1] + data[i + 2]) / 3);
      }
      
      let laplacianSum = 0;
      for (let y = 1; y < size - 1; y++) {
        for (let x = 1; x < size - 1; x++) {
          const idx = y * size + x;
          const laplacian = 
            -gray[idx - size] - gray[idx - 1] + 4 * gray[idx] - gray[idx + 1] - gray[idx + size];
          laplacianSum += laplacian * laplacian;
        }
      }
      
      const variance = laplacianSum / ((size - 2) * (size - 2));
      const normalizedSharpness = Math.min(100, variance / 10);
      
      resolve(Math.round(normalizedSharpness));
    };
    img.src = imageData;
  });
}

// Detect face region (simplified - returns center region as placeholder)
export function detectFaceRegion(imageData) {
  return new Promise((resolve) => {
    const img = new Image();
    img.onload = () => {
      // Simplified face detection - returns center region
      // In production, would use ML model
      const faceRegion = {
        x: img.width * 0.25,
        y: img.height * 0.15,
        width: img.width * 0.5,
        height: img.height * 0.6,
      };
      
      const faceSize = (faceRegion.width * faceRegion.height) / (img.width * img.height);
      
      resolve({
        detected: true, // Always true for demo
        region: faceRegion,
        size: faceSize,
        confidence: 0.85,
      });
    };
    img.src = imageData;
  });
}

// Get image dimensions
export function getImageDimensions(imageData) {
  return new Promise((resolve) => {
    const img = new Image();
    img.onload = () => {
      resolve({
        width: img.width,
        height: img.height,
        aspectRatio: img.width / img.height,
      });
    };
    img.src = imageData;
  });
}

// Crop image to face region
export function cropToFace(imageData, faceRegion, padding = 0.2) {
  return new Promise((resolve) => {
    const img = new Image();
    img.onload = () => {
      const { x, y, width, height } = faceRegion;
      
      // Add padding
      const paddedX = Math.max(0, x - width * padding);
      const paddedY = Math.max(0, y - height * padding);
      const paddedWidth = Math.min(img.width - paddedX, width * (1 + 2 * padding));
      const paddedHeight = Math.min(img.height - paddedY, height * (1 + 2 * padding));
      
      const canvas = document.createElement('canvas');
      canvas.width = paddedWidth;
      canvas.height = paddedHeight;
      
      const ctx = canvas.getContext('2d');
      ctx.drawImage(
        img,
        paddedX, paddedY, paddedWidth, paddedHeight,
        0, 0, paddedWidth, paddedHeight
      );
      
      resolve(canvas.toDataURL('image/jpeg', 0.92));
    };
    img.src = imageData;
  });
}

export default {
  base64ToBlob,
  blobToBase64,
  resizeImage,
  calculateBrightness,
  calculateSharpness,
  detectFaceRegion,
  getImageDimensions,
  cropToFace,
};

