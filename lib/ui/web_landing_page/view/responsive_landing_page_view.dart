// lib/ui/landing_page/views/responsive_landing_page_view.dart
import 'package:flutter/material.dart';
import '../../core/ui/responsive_layout.dart';
import '../../web_landing_page/view/web_landing_page_view.dart';
import '../../web_landing_page/view/mobile_landing_page_view.dart';

class ResponsiveLandingPageView extends StatelessWidget {
  /// Optional initial section to scroll to on load (used by deep-link routes).
  final String? initialSection;

  const ResponsiveLandingPageView({super.key, this.initialSection});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileView: MobileLandingPageView(initialSection: initialSection),
      desktopView: WebLandingPageView(initialSection: initialSection),
    );
  }
}
