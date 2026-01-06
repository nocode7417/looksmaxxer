import 'package:flutter/material.dart';

/// 8pt grid spacing system matching the original design
class AppSpacing {
  AppSpacing._();

  // Base unit: 4px
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double massive = 48;

  // Semantic spacing
  static const double pagePadding = 16;
  static const double cardPadding = 16;
  static const double sectionGap = 24;
  static const double itemGap = 12;
  static const double iconGap = 8;

  // Border radius
  static const double radiusXs = 4;
  static const double radiusSm = 6;
  static const double radiusMd = 8;
  static const double radiusLg = 12;
  static const double radiusXl = 16;
  static const double radiusXxl = 20;
  static const double radiusFull = 9999;

  // Border radius as BorderRadius
  static final BorderRadius borderRadiusXs = BorderRadius.circular(radiusXs);
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
  static final BorderRadius borderRadiusXxl = BorderRadius.circular(radiusXxl);
  static final BorderRadius borderRadiusFull = BorderRadius.circular(radiusFull);

  // Edge insets helpers
  static const EdgeInsets paddingAll = EdgeInsets.all(lg);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingPage = EdgeInsets.symmetric(horizontal: pagePadding);
  static const EdgeInsets paddingCard = EdgeInsets.all(cardPadding);

  // Safe area aware padding
  static EdgeInsets safeAreaPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top + lg,
      bottom: mediaQuery.padding.bottom + lg,
      left: pagePadding,
      right: pagePadding,
    );
  }
}
