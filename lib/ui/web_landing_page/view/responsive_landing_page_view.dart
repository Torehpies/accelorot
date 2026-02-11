// lib/ui/landing_page/views/responsive_landing_page_view.dart
import 'package:flutter/material.dart';
import '../../core/ui/responsive_layout.dart';
import '../../web_landing_page/view/web_landing_page_view.dart';
import '../../web_landing_page/view/mobile_landing_page_view.dart';

class ResponsiveLandingPageView extends StatelessWidget {
  const ResponsiveLandingPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileView: MobileLandingPageView(),
      desktopView: WebLandingPageView(),
    );
  }
}