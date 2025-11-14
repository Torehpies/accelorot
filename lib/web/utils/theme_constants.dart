// lib/utils/theme_constants.dart

import 'package:flutter/material.dart';

class ThemeConstants {
  // Colors
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color tealColor = Color(0xFF008080);
  static Color tealShade50 = Colors.teal.shade50;
  static Color tealShade100 = Colors.teal.shade100;
  static Color tealShade200 = Colors.teal.shade200;
  static Color tealShade300 = Colors.teal.shade300;
  static Color tealShade600 = Colors.teal.shade600;
  static Color tealShade700 = Colors.teal.shade700;
  static Color tealShade800 = Colors.teal.shade800;

  static Color orangeShade50 = Colors.orange.shade50;
  static Color orangeShade600 = Colors.orange.shade600;

  static Color blueShade50 = Colors.blue.shade50;
  static Color blueShade600 = Colors.blue.shade600;

  static Color greenShade50 = Colors.green.shade50;
  static Color greenShade600 = Colors.green.shade600;

  static Color greyShade50 = Colors.grey[50]!;
  static Color greyShade100 = Colors.grey[100]!;
  static Color greyShade200 = Colors.grey[200]!;
  static Color greyShade300 = Colors.grey[300]!;
  static Color greyShade400 = Colors.grey[400]!;
  static Color greyShade500 = Colors.grey[500]!;
  static Color greyShade600 = Colors.grey[600]!;
  static Color greyShade700 = Colors.grey[700]!;

  static const Color borderColor = Color.fromARGB(255, 170, 169, 169);

  // Border Radius
  static const double borderRadius6 = 6.0;
  static const double borderRadius8 = 8.0;
  static const double borderRadius10 = 10.0;
  static const double borderRadius12 = 12.0;
  static const double borderRadius16 = 16.0;
  static const double borderRadius20 = 20.0;
  static const double borderRadius24 = 24.0;

  // Sizes
  static const double iconSize14 = 14.0;
  static const double iconSize15 = 15.0;
  static const double iconSize18 = 18.0;
  static const double iconSize20 = 20.0;
  static const double iconSize22 = 22.0;
  static const double iconSize24 = 24.0;
  static const double iconSize28 = 28.0;

  static const double avatarSize44 = 44.0;
  static const double avatarSize48 = 48.0;
  static const double avatarSize56 = 56.0;

  // Animation
  static const int animationDuration = 300;
  static const Duration animationDurationMs = Duration(milliseconds: 300);

  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;

  // Font Sizes
  static const double fontSize9 = 9.0;
  static const double fontSize11 = 11.0;
  static const double fontSize12 = 12.0;
  static const double fontSize13 = 13.0;
  static const double fontSize14 = 14.0;
  static const double fontSize15 = 15.0;
  static const double fontSize16 = 16.0;
  static const double fontSize18 = 18.0;
  static const double fontSize20 = 20.0;
  static const double fontSize32 = 32.0;

  // Border Radius Styles
  static BorderRadius borderRadiusCircular(double radius) {
    return BorderRadius.circular(radius);
  }

  static RoundedRectangleBorder roundedRectangleBorder(double radius) {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }
}
