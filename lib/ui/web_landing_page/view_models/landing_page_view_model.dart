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
      description: 'Monitor composting anytime, anywhere via our mobile app',
      icon: Icons.smartphone_outlined,
      iconColor: WebColors.greenAccent,
      backgroundColor: const Color(0xFFCCFBF1),
    ),
    FeatureModel(
      title: 'AI Recommendations',
      description: 'Get AI-powered tips for ideal composting conditions.',
      icon: Icons.psychology_outlined,
      iconColor: WebColors.greenAccent,
      backgroundColor: const Color(0xFFCCFBF1),
    ),
    FeatureModel(
      title: 'Auto-Regulation',
      description: 'Auto aeration & moisture control for perfect compost',
      icon: Icons.bolt_outlined,
      iconColor: WebColors.greenAccent,
      backgroundColor: const Color(0xFFCCFBF1),
    ),
    FeatureModel(
      title: 'Smart Alerts',
      description:
          'Receive notifications for critical events and compost readiness',
      icon: Icons.notifications_outlined,
      iconColor: WebColors.greenAccent,
      backgroundColor: const Color(0xFFCCFBF1),
    ),
    FeatureModel(
      title: 'Data Analytics',
      description:
          'Track trends with interactive graphs and exportable reports',
      icon: Icons.analytics_outlined,
      iconColor: WebColors.greenAccent,
      backgroundColor: const Color(0xFFCCFBF1),
    ),
    FeatureModel(
      title: 'Eco-Friendly',
      description:
          'Reduce waste, lower emissions, and create sustainable compost',
      icon: Icons.eco_outlined,
      iconColor: WebColors.greenAccent,
      backgroundColor: const Color(0xFFCCFBF1),
    ),
  ];

  // Steps data
  List<StepModel> get steps => [
    StepModel(
      number: 1,
      title: 'Add Materials',
      description:
        'Simply add your greens (nitrogen-rich), browns (carbon-rich), and starter compost into the rotary drum.',
    ),
    StepModel(
      number: 2,
      title: 'Monitor Sensors',
      description:
          'IoT sensors continuously track temperature, moisture, and air quality—adjusting conditions automatically.',
    ),
    StepModel(
      number: 3,
      title: 'AI Recommendations',
      description:
          'Receive intelligent suggestions on moisture levels, aeration frequency, and optimal harvest timing.',
    ),
    StepModel(
      number: 4,
      title: 'Harvest Quality Compost',
      description:
          'Receive alerts when pathogen-free, mature compost is ready in 14 days',
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
