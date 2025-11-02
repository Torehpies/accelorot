import 'package:flutter/material.dart';
import '../components/all_activity_section.dart';
import '../components/substrate_section.dart';
import '../components/alerts_section.dart';
import '../components/cycles_recom_section.dart';

class ActivityLogsNavigator extends StatelessWidget {
  final String? focusedMachineId; // ⭐ NEW

  const ActivityLogsNavigator({
    super.key,
    this.focusedMachineId, // ⭐ NEW
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          focusedMachineId != null ? "Machine Activity Logs" : "Activity Logs", // ⭐ Dynamic title
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ⭐ Show banner when in machine view
              if (focusedMachineId != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade50, Colors.teal.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_alt, color: Colors.teal.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Showing activities for this machine only',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              AllActivitySection(
                focusedMachineId: focusedMachineId, // ⭐ Pass filter
              ),
              const SizedBox(height: 16),
              SubstrateSection(
                focusedMachineId: focusedMachineId, // ⭐ Pass filter
              ),
              const SizedBox(height: 16),
              AlertsSection(
                focusedMachineId: focusedMachineId, // ⭐ Pass filter
              ),
              const SizedBox(height: 16),
              CyclesRecomSection(
                focusedMachineId: focusedMachineId, // ⭐ Pass filter
              ),
            ],
          ),
        ),
      ),
    );
  }
}