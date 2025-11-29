// lib/ui/activity_logs/widgets/activity_section_card.dart

import 'package:flutter/material.dart';
import '../models/activity_filter_config.dart';
import 'filter_box.dart';

/// Reusable section card for activity logs with filter boxes
class ActivitySectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String viewAllRoute;
  final List<FilterConfig> filters;
  final String? focusedMachineId;

  const ActivitySectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.viewAllRoute,
    required this.filters,
    this.focusedMachineId,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header with title and view all button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: Colors.teal.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(viewAllRoute);
                    },
                    child: Text(
                      'View All >',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.teal.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filter boxes
              Expanded(
                child: Row(
                  children: _buildFilterBoxesWithSpacing(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds filter boxes with 8px spacing between them
  List<Widget> _buildFilterBoxesWithSpacing(BuildContext context) {
    final List<Widget> widgets = [];
    
    for (int i = 0; i < filters.length; i++) {
      final filter = filters[i];
      
      widgets.add(
        FilterBox(
          icon: filter.icon,
          label: filter.label,
          filterValue: filter.filterValue,
          onTap: () {
            Navigator.of(context).pushNamed(
              filter.route,
              arguments: {
                'initialFilter': filter.initialFilterArg ?? filter.filterValue
              },
            );
          },
        ),
      );
      
      // Add spacing between boxes (but not after the last one)
      if (i < filters.length - 1) {
        widgets.add(const SizedBox(width: 8));
      }
    }
    
    return widgets;
  }
}