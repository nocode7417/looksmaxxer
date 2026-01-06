import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Face alignment guide overlay for camera
class AlignmentGuide extends StatelessWidget {
  const AlignmentGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: AlignmentGuidePainter(),
    );
  }
}

class AlignmentGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Face oval dimensions
    final ovalWidth = size.width * 0.6;
    final ovalHeight = size.height * 0.45;

    // Draw face oval
    final ovalRect = Rect.fromCenter(
      center: Offset(centerX, centerY - 20),
      width: ovalWidth,
      height: ovalHeight,
    );
    canvas.drawOval(ovalRect, paint);

    // Draw center crosshair (subtle)
    final crosshairPaint = Paint()
      ..color = AppColors.textPrimary.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Vertical line
    canvas.drawLine(
      Offset(centerX, centerY - 30),
      Offset(centerX, centerY + 30),
      crosshairPaint,
    );

    // Horizontal line
    canvas.drawLine(
      Offset(centerX - 30, centerY),
      Offset(centerX + 30, centerY),
      crosshairPaint,
    );

    // Draw corner guides
    final cornerPaint = Paint()
      ..color = AppColors.textPrimary.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    final left = centerX - ovalWidth / 2;
    final right = centerX + ovalWidth / 2;
    final top = centerY - 20 - ovalHeight / 2;
    final bottom = centerY - 20 + ovalHeight / 2;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + cornerLength),
      Offset(left, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(right - cornerLength, top),
      Offset(right, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, top),
      Offset(right, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, bottom - cornerLength),
      Offset(left, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, bottom),
      Offset(left + cornerLength, bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(right - cornerLength, bottom),
      Offset(right, bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(right, bottom),
      Offset(right, bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
