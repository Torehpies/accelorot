// lib/ui/activity_logs/mappers/activity_presentation_mapper.dart

import '../../../data/models/substrate.dart';
import '../../../data/models/alert.dart';
import '../../../data/models/report.dart';
import '../../../data/models/cycle_recommendation.dart';
import '../models/activity_log_item.dart';
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
    // Build description
    final description = 'Sensor: ${_toProperCase(alert.sensorType)}\n'
        'Reading: ${alert.readingValue}\n'
        'Threshold: ${alert.threshold} (${alert.status})';

    return ActivityLogItem(
      id: alert.id,
      title: _toProperCase(alert.message),
      value: '${alert.readingValue}',
      statusColor: ActivityColorMapper.getColorForAlert(alert.status),
      icon: ActivityIconMapper.getIconForAlert(alert.sensorType),
      description: description,
      category: alert.displayCategory,
      timestamp: alert.timestamp,
      type: ActivityType.alert,
      machineId: alert.machineId,
    );
  }

  // ===== REPORT → ActivityLogItem =====
  
  static ActivityLogItem fromReport(Report report) {
    // Build description
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
      value: report.displayStatus,
      statusColor: ActivityColorMapper.getColorForReportPriority(report.priority),
      icon: ActivityIconMapper.getIconForReport(report.reportType),
      description: description,
      category: report.displayReportType,
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
    return ActivityLogItem(
      id: cycle.id,
      title: cycle.title,
      value: cycle.value,
      statusColor: ActivityColorMapper.getColorForCycle(cycle.category),
      icon: ActivityIconMapper.getIconForCycle(cycle.category),
      description: cycle.description,
      category: cycle.category,
      timestamp: cycle.timestamp,
      type: ActivityType.cycle,
      machineId: cycle.machineId,
    );
  }

  // ===== HELPERS =====
  
  static String _toProperCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}