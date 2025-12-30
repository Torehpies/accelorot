// lib/ui/activity_logs/mappers/activity_presentation_mapper.dart

import 'package:flutter/material.dart';

import '../../../data/models/substrate.dart';
import '../../../data/models/alert.dart';
import '../../../data/models/report.dart';
import '../../../data/models/cycle_recommendation.dart';
import '../../../data/models/activity_log_item.dart';
import 'icon_mapper.dart';
import 'color_mapper.dart';

/// Transforms data models to UI presentation models
class ActivityPresentationMapper {
  // ===== SUBSTRATE → ActivityLogItem =====

  static ActivityLogItem fromSubstrate(Substrate substrate) {
    return ActivityLogItem(
      id: substrate.id,
      title: substrate.title,
      value: '${substrate.quantity}kg',
      statusColor: ActivityColorMapper.getColorForSubstrate(substrate.category),
      icon: ActivityIconMapper.getIconForSubstrate(substrate.category),
      description: substrate.description,
      category: substrate.category,
      timestamp: substrate.timestamp,
      type: ActivityType.substrate,
      machineId: substrate.machineId,
      machineName: substrate.machineName,
      batchId: substrate.batchId,
      operatorName: substrate.operatorName,
    );
  }

  // ===== ALERT → ActivityLogItem =====

  static ActivityLogItem fromAlert(Alert alert) {
    // Use helper instead of alert.displayCategory (which we removed)
    final category = _getAlertDisplayCategory(alert.sensorType);

    final description =
        'Sensor: ${_toProperCase(alert.sensorType)}\n'
        'Reading: ${alert.readingValue}\n'
        'Threshold: ${alert.threshold} (${alert.status})';

    return ActivityLogItem(
      id: alert.id,
      title: _toProperCase(alert.message),
      value: '${alert.readingValue}',
      statusColor: ActivityColorMapper.getColorForAlert(alert.status),
      icon: ActivityIconMapper.getIconForAlert(alert.sensorType),
      description: description,
      category: category,
      timestamp: alert.timestamp,
      type: ActivityType.alert,
      machineId: alert.machineId,
    );
  }

  // ===== REPORT → ActivityLogItem =====

  static ActivityLogItem fromReport(Report report) {
    // Use helpers instead of report.displayX methods (which we removed)
    final displayReportType = _getReportDisplayType(report.reportType);
    final displayStatus = _getDisplayStatus(report.status);

    final parts = <String>[];

    if (report.description.isNotEmpty) {
      parts.add(report.description);
    }

    parts.add('Machine: ${report.machineName}');
    parts.add('By: ${report.userName}');

    final description = parts.join('\n');

    return ActivityLogItem(
      id: report.id,
      title: report.title,
      value: displayStatus,
      statusColor: ActivityColorMapper.getColorForReportPriority(
        report.priority,
      ),
      icon: ActivityIconMapper.getIconForReport(report.reportType),
      description: description,
      category: displayReportType,
      timestamp: report.createdAt,
      type: ActivityType.report,
      machineId: report.machineId,
      machineName: report.machineName,
      operatorName: report.userName,
      priority: report.priority,
      status: report.status,
    );
  }

  // ===== CYCLE RECOMMENDATION → ActivityLogItem =====

  static ActivityLogItem fromCycleRecommendation(CycleRecommendation cycle) {
    // Determine title based on controller type
    final title = cycle.controllerType == 'drum_controller' 
        ? 'Drum Controller' 
        : 'Aerator';
        // Build description
    final parts = <String>[];
    parts.add('Duration: ${cycle.duration ?? "N/A"}');
    parts.add('Cycles: ${cycle.completedCycles ?? 0}/${cycle.cycles ?? 0}');
    

    if (cycle.totalRuntimeSeconds != null) {
    final runtime = Duration(seconds: cycle.totalRuntimeSeconds!);
    final hours = runtime.inHours;
    final minutes = runtime.inMinutes.remainder(60);
    parts.add('Runtime: ${hours}h ${minutes}m');
    }


    
    return ActivityLogItem(
      id: cycle.id,
      title: title,
      value: cycle.status ?? 'unknown',
      statusColor: _getCycleStatusColor(cycle.status),
      icon: _getCycleIcon(cycle.controllerType),
      description: parts.join('\n'),
      category: cycle.controllerType, // ?? 'cycles', 
      timestamp: cycle.timestamp ?? cycle.startedAt ?? DateTime.now(),
      type: ActivityType.cycle,
      machineId: cycle.machineId,
      batchId: cycle.batchId,
      status: cycle.status,
      controllerType: cycle.controllerType,
      cycles: cycle.cycles,
      duration: cycle.duration,
      completedCycles: cycle.completedCycles,
      totalRuntimeSeconds: cycle.totalRuntimeSeconds,
    );
  }

  // ===== PRIVATE HELPERS (Moved from models) =====

  static Color _getCycleStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'running':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'stopped':
        return Colors.red;
      case 'idle':
      default:
        return Colors.grey;
    }
  }

  static IconData _getCycleIcon(String? controllerType) {
    switch (controllerType) {
      case 'drum_controller':
        return Icons.sync; // or Icons.rotate_right
      case 'aerator':
        return Icons.air;
      default:
        return Icons.settings;
    }
  }


  /// Get display category for alerts (moved from Alert model)
  static String _getAlertDisplayCategory(String sensorType) {
    final lower = sensorType.toLowerCase();
    if (lower.contains('temp')) return 'Temperature';
    if (lower.contains('moisture')) return 'Moisture';
    if (lower.contains('oxygen') || lower.contains('air')) return 'Air Quality';
    return 'Other';
  }

  /// Get display type for reports (moved from Report model)
  static String _getReportDisplayType(String reportType) {
    switch (reportType.toLowerCase()) {
      case 'maintenance_issue':
        return 'Maintenance';
      case 'observation':
        return 'Observation';
      case 'safety_concern':
        return 'Safety';
      default:
        return 'Unknown';
    }
  }

  /// Get display status (moved from Report model)
  static String _getDisplayStatus(String status) {
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }

  /// Helper to convert to proper case
  static String _toProperCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}
