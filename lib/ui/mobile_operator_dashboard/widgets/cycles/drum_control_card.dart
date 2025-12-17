// lib/frontend/operator/dashboard/cycles/system_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/mobile_operator_dashboard/widgets/view_model/compost_progress/compost_batch_model.dart';
import 'package:flutter_application_1/ui/mobile_operator_dashboard/widgets/view_model/cycles/drum_rotation_settings.dart';
import 'package:flutter_application_1/ui/mobile_operator_dashboard/widgets/view_model/cycles/system_status.dart';
import 'package:flutter_application_1/ui/home_screen/cycles/empty_state.dart';
import 'package:flutter_application_1/ui/home_screen/cycles/info_item.dart';

class DrumControlCard extends StatefulWidget {
  final CompostBatch? currentBatch;

  const DrumControlCard({super.key, this.currentBatch});

  @override
  State<DrumControlCard> createState() => _DrumControlCardState();
}

class _DrumControlCardState extends State<DrumControlCard> {
  DrumRotationSettings settings = DrumRotationSettings();
  SystemStatus status = SystemStatus.idle;
  
  String? _uptime = '00:00:00';
  int _completedCycles = 0;

  @override
  void initState() {
    super.initState();
    if (widget.currentBatch != null) {
      // Initialize with default settings when batch is active
      settings = DrumRotationSettings();
    }
  }

  @override
  void didUpdateWidget(DrumControlCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset when batch changes
    if (oldWidget.currentBatch != widget.currentBatch) {
      if (widget.currentBatch == null) {
        setState(() {
          settings.reset();
          status = SystemStatus.idle;
          _uptime = '00:00:00';
          _completedCycles = 0;
        });
      }
    }
  }

  void _handleStart() {
    setState(() {
      status = SystemStatus.running;
      // Start uptime tracking here if needed
    });
  }

  String _getCyclesLabel(int cycles) {
    return '$cycles Cycles';
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveBatch = widget.currentBatch != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Drum Controller',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                    letterSpacing: -0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: hasActiveBatch
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hasActiveBatch ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: hasActiveBatch
                          ? const Color(0xFF065F46)
                          : const Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content based on batch state
            if (!hasActiveBatch)
              const Expanded(child: EmptyState())
            else
              _buildActiveState(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info Grid - Machine Name and Batch Name
        Row(
          children: [
            Expanded(
              child: InfoItem(
                label: 'Machine Name',
                value: 'Sample Text...',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InfoItem(
                label: 'Batch Name',
                value: widget.currentBatch!.batchName,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Info Grid - Uptime and No. of Cycles
        Row(
          children: [
            Expanded(
              child: InfoItem(
                label: 'Uptime',
                value: _uptime ?? '00:00:00',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InfoItem(
                label: 'No. of Cycles',
                value: _completedCycles.toString(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Set Controller Section
        const Text(
          'Set Controller',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1a1a1a),
          ),
        ),
        const SizedBox(height: 12),

        // Dropdowns Row
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                label: 'Select Duration',
                value: settings.period,
                items: ['15 minutes', '30 minutes', '1 hour', '2 hours'],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      settings = settings.copyWith(period: value);
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                label: 'Select No. of Cycles',
                value: _getCyclesLabel(settings.cycles),
                items: ['50 Cycles', '100 Cycles', '150 Cycles', '200 Cycles'],
                onChanged: (value) {
                  if (value != null) {
                    final cycles = int.parse(value.split(' ')[0]);
                    setState(() {
                      settings = settings.copyWith(cycles: cycles);
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Start Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: status == SystemStatus.idle ? _handleStart : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: Text(
              status == SystemStatus.idle ? 'Start' : status.displayName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          isDense: true,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey.shade600,
            size: 20,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}