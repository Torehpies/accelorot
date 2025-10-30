import 'package:flutter/material.dart';
import '../components/all_activity_section.dart';
import '../components/substrate_section.dart';
import '../components/alerts_section.dart';
import '../components/cycles_recom_section.dart';

class ActivityLogsNavigator extends StatelessWidget {
  final String? viewingOperatorId; // ⭐ NEW: Support for admin viewing operator

  const ActivityLogsNavigator({
    super.key,
    this.viewingOperatorId, // ⭐ NEW
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Activity Logs",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AllActivitySection(
                viewingOperatorId: viewingOperatorId, // ⭐ Pass down
              ),
              const SizedBox(height: 16),
              SubstrateSection(
                viewingOperatorId: viewingOperatorId, // ⭐ Pass down
              ),
              const SizedBox(height: 16),
              AlertsSection(
                viewingOperatorId: viewingOperatorId, // ⭐ Pass down
              ),
              const SizedBox(height: 16),
              CyclesRecomSection(
                viewingOperatorId: viewingOperatorId, // ⭐ Pass down
              ),
            ],
          ),
        ),
      ),
    );
  }
}