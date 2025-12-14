// lib/frontend/operator/dashboard/cycles/system_card.dart

import 'package:flutter/material.dart';
import '../view_model/cycles/drum_rotation_settings.dart';
import '../view_model/cycles/system_status.dart';
import '../../../home_screen/cycles/empty_state.dart';
import '../../../home_screen/cycles/active_state.dart';
import '../view_model/compost_progress/compost_batch_model.dart';

class SystemCard extends StatefulWidget {
  final CompostBatch? currentBatch;

  const SystemCard({super.key, required this.currentBatch});

  @override
  State<SystemCard> createState() => _SystemCardState();
}

class _SystemCardState extends State<SystemCard> {
  DrumRotationSettings _settings = DrumRotationSettings();
  SystemStatus _status = SystemStatus.idle;

  @override
  void didUpdateWidget(SystemCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset when batch changes
    if (oldWidget.currentBatch != widget.currentBatch) {
      if (widget.currentBatch == null) {
        // Batch completed/removed - reset everything
        setState(() {
          _settings.reset();
          _status = SystemStatus.idle;
        });
      }
    }
  }

  bool get _hasActiveBatch => widget.currentBatch != null;

  String get _batchNumber => widget.currentBatch?.batchNumber ?? '';

  DateTime get _batchStartTime =>
      widget.currentBatch?.batchStart ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 16),

            // Content - Empty or Active state
            if (!_hasActiveBatch)
              const EmptyState()
            else
              ActiveState(
                batchNumber: _batchNumber,
                batchStartTime: _batchStartTime,
                settings: _settings,
                status: _status,
                onStatusChanged: (newStatus) {
                  setState(() => _status = newStatus);
                },
                onSettingsChanged: (newSettings) {
                  setState(() => _settings = newSettings);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.settings, color: Colors.teal.shade700, size: 20),
            const SizedBox(width: 8),
            const Text(
              'System',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        if (_hasActiveBatch)
          Row(
            children: [
              Text(
                'Status: ',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _status.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _status.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_status.icon, size: 14, color: _status.color),
                    const SizedBox(width: 4),
                    Text(
                      _status.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: _status.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
