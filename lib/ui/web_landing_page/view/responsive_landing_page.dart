
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/responsive_layout.dart';
import 'landing_page_view.dart';
import 'mobile_landing_page_view.dart';

class ResponsiveLandingPage extends StatelessWidget {

  const ResponsiveLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileView: MobileLandingPageView(),
      desktopView: LandingPageView(),
    );
  }
}
