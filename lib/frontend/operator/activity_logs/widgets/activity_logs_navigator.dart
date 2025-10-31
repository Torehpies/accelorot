// lib/frontend/operator/activity_logs/activity_logs_navigator.dart
import 'package:flutter/material.dart';
import '../components/all_activity_section.dart';
import '../components/substrate_section.dart';
import '../components/alerts_section.dart';
import '../components/cycles_recom_section.dart';
import '../components/batch_filter_section.dart';

class ActivityLogsNavigator extends StatelessWidget {
  final String? viewingOperatorId;

  const ActivityLogsNavigator({
    super.key,
    this.viewingOperatorId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light grey background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Activity Logs",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Padding(
          // Outer padding for the screen content
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  // Main White Content Container
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // ⭐ UPDATED: Only top-left and top-right corners are rounded
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    border: Border.all(color: Colors.grey[300]!, width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 1. The Shadow-Casting Header (Batch Filter)
                      const BatchFilterSection(),
                      
                      // 2. The Scrolling Content Area
                      Expanded(
                        child: SingleChildScrollView(
                          // Padding is 16 all around to make the list content look embedded
                          padding: const EdgeInsets.all(16.0), 
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AllActivitySection(
                                viewingOperatorId: viewingOperatorId,
                              ),
                              const SizedBox(height: 16),
                              SubstrateSection(
                                viewingOperatorId: viewingOperatorId,
                              ),
                              const SizedBox(height: 16),
                              AlertsSection(
                                viewingOperatorId: viewingOperatorId,
                              ),
                              const SizedBox(height: 16),
                              CyclesRecomSection(
                                viewingOperatorId: viewingOperatorId,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}