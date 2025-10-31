// lib/frontend/operator/dashboard/cycles/system_card.dart

import 'package:flutter/material.dart';
import 'widgets/input_fields.dart';
import 'widgets/action_buttons.dart';

class SystemCard extends StatefulWidget {
  const SystemCard({super.key});

  @override
  State<SystemCard> createState() => _SystemCardState();
}

class _SystemCardState extends State<SystemCard> {
  // --- 1. STATE MANAGEMENT ---
  String status = "Excellent"; // "Excellent", "Warning", "Error"
  String selectedPeriod = "1 hour";
  String selectedCycle = "100";
  bool isRunning = false;
  bool isPaused = false;

  // --- 2. HELPER FUNCTIONS ---
  Color getStatusColor() {
    switch (status) {
      case "Excellent":
        return Colors.green;
      case "Warning":
        return Colors.orange;
      case "Error":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon() {
    switch (status) {
      case "Excellent":
        return Icons.check_circle;
      case "Warning":
        return Icons.warning;
      case "Error":
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  // Method to update state from child widgets - **FIXED NAMED PARAMETER**
  void updateState({
    String? newStatus,
    String? newCycle,
    String? newPeriod,
    bool? isRunning,
    bool? paused,
  }) {
    setState(() {
      status = newStatus ?? status;
      selectedCycle = newCycle ?? selectedCycle;
      selectedPeriod = newPeriod ?? selectedPeriod;
      this.isRunning =
          isRunning ??
          this.isRunning; // Correctly uses the 'isRunning' parameter
      isPaused = paused ?? isPaused;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.settings, size: 18, color: Colors.black54),
                  SizedBox(width: 6),
                  Text(
                    'System',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Status: ',
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      color: getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(getStatusIcon(), color: getStatusColor(), size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Uptime info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Uptime\n12:12:12', style: TextStyle(color: Colors.black87)),
              Text(
                'Last Update\n12:12:13 Aug 30, 2025',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text(
            'Drum Rotation',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),

          // 1. Drum Input Fields
          DrumInputFields(
            selectedCycle: selectedCycle,
            selectedPeriod: selectedPeriod,
            onCycleChanged: (value) => updateState(newCycle: value),
            onPeriodChanged: (value) => updateState(newPeriod: value),
          ),

          const SizedBox(height: 20),

          // 2. Action Buttons (The calls now match the function definition)
          SystemActionButtons(
            isRunning: isRunning,
            isPaused: isPaused,
            onStart: () => updateState(isRunning: true, newStatus: "Excellent"),
            onStop: () => updateState(
              isRunning: false,
              paused: false,
              newStatus: "Excellent",
            ), // FIXED
            onTogglePause: () => updateState(
              paused: !isPaused,
              newStatus: !isPaused ? "Warning" : "Excellent",
            ),
          ),
        ],
      ),
    );
  }
}
