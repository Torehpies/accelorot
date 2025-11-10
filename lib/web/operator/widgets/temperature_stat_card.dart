// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_application_1/frontend/operator/statistics/view_screens/temperature_stats_view.dart'
    show TemperatureStatsView;

class TemperatureStatCard extends StatelessWidget {
  final VoidCallback? onTap;

  const TemperatureStatCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return _buildCard(context, const TemperatureStatsView());
  }

  Widget _buildCard(BuildContext context, Widget child) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
