// lib/ui/landing_page/view_model/landing_page_view_model.dart

import 'package:flutter/material.dart';
import '../models/feature_model.dart';
import '../models/step_model.dart';
import '../models/impact_stat_model.dart';
import '../../core/themes/web_colors.dart';

class LandingPageViewModel extends ChangeNotifier {
  // Features data
  List<FeatureModel> get features => [
        FeatureModel(
          title: 'Mobile Dashboard',
          description:
              'Monitor your composting process anywhere with our intuitive mobile app',
          icon: Icons.smartphone_outlined,
          iconColor: WebColors.tealAccent,
          backgroundColor: const Color(0xFFCCFBF1),
        ),
        FeatureModel(
          title: 'AI Recommendations',
          description:
              'Get smart suggestions based on real-time data for optimal composting conditions',
          icon: Icons.psychology_outlined,
          iconColor: WebColors.tealAccent,
          backgroundColor: const Color(0xFFCCFBF1),
        ),
        FeatureModel(
          title: 'Auto-Regulation',
          description:
              'Automated aeration and moisture control maintain perfect conditions',
          icon: Icons.bolt_outlined,
          iconColor: WebColors.tealAccent,
          backgroundColor: const Color(0xFFCCFBF1),
        ),
        FeatureModel(
          title: 'Smart Alerts',
          description:
              'Receive notifications for critical events and compost readiness',
          icon: Icons.notifications_outlined,
          iconColor: WebColors.tealAccent,
          backgroundColor: const Color(0xFFCCFBF1),
        ),
        FeatureModel(
          title: 'Data Analytics',
          description:
              'Track trends with interactive graphs and exportable reports',
          icon: Icons.analytics_outlined,
          iconColor: WebColors.tealAccent,
          backgroundColor: const Color(0xFFCCFBF1),
        ),
        FeatureModel(
          title: 'Eco-Friendly',
          description:
              'Reduce waste, lower emissions, and create sustainable compost',
          icon: Icons.eco_outlined,
          iconColor: WebColors.tealAccent,
          backgroundColor: const Color(0xFFCCFBF1),
        ),
      ];

  // Steps data
  List<StepModel> get steps => [
        StepModel(
          number: 1,
          title: 'Add Materials',
          description:
              'Load organic waste, greens (nitrogen), and browns (carbon) into the drum',
        ),
        StepModel(
          number: 2,
          title: 'Monitor Sensors',
          description:
              'IoT sensors track temperature, humidity, moisture, and oxygen levels',
        ),
        StepModel(
          number: 3,
          title: 'Auto-Regulate',
          description:
              'System automatically adjusts aeration and moisture for optimal conditions',
        ),
        StepModel(
          number: 4,
          title: 'Harvest Compost',
          description:
              'Receive alerts when pathogen-free, mature compost is ready in 2 weeks',
        ),
      ];

  // Impact stats data
  List<ImpactStatModel> get impactStats => [
        ImpactStatModel(value: '50%+', label: 'Organic Waste in PH'),
        ImpactStatModel(value: '2\nWeeks', label: 'Compost Time'),
        ImpactStatModel(value: '24/7', label: 'Automated'),
        ImpactStatModel(value: '100%', label: 'Safe & Quality'),
      ];

  void onGetStarted() {
    // Navigate to sign up or onboarding
    debugPrint('Get Started clicked');
  }

  void onLearnMore() {
    // Navigate to detailed information page
    debugPrint('Learn More clicked');
  }

  void onLogin() {
    // Navigate to login page
    debugPrint('Login clicked');
  }
}