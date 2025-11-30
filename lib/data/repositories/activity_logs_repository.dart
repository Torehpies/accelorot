// lib/data/repositories/activity_logs_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../ui/activity_logs/models/activity_log_item.dart';
import '../../ui/activity_logs/mappers/activity_presentation_mapper.dart';
import '../services/firebase/activity_logs/substrate_service.dart';
import '../services/firebase/activity_logs/alert_service.dart';
import '../services/firebase/activity_logs/report_service.dart';
import '../services/firebase/activity_logs/cycle_service.dart';
import 'activity_repository.dart';

/// Firestore implementation of ActivityRepository
/// Orchestrates services and transforms data to UI models
class ActivityLogsRepository implements ActivityRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== USER MANAGEMENT =====

  /// Get current logged-in user ID
  String? _getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  /// Get effective user ID (viewing operator or current user)
  String _getEffectiveUserId(String? viewingOperatorId) {
    return viewingOperatorId ?? _getCurrentUserId() ?? '';
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      final userId = _getCurrentUserId();
      return userId != null && userId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ===== FETCH METHODS - ORCHESTRATION + TRANSFORMATION =====

  @override
  Future<List<ActivityLogItem>> getSubstrates({
    String? viewingOperatorId,
  }) async {
    try {
      final effectiveUserId = _getEffectiveUserId(viewingOperatorId);
      
      // Fetch from service (returns data models)
      final substrates = await SubstrateService.fetchSubstrates(effectiveUserId);
      
      // Transform to UI models
      return substrates
          .map((substrate) => ActivityPresentationMapper.fromSubstrate(substrate))
          .toList();
    } catch (e) {
      debugPrint('Repository error fetching substrates: $e');
      rethrow;
    }
  }

  @override
  Future<List<ActivityLogItem>> getAlerts({
    String? viewingOperatorId,
  }) async {
    try {
      final effectiveUserId = _getEffectiveUserId(viewingOperatorId);
      
      // Fetch from service (returns data models)
      final alerts = await AlertService.fetchAlerts(effectiveUserId);
      
      // Transform to UI models
      return alerts
          .map((alert) => ActivityPresentationMapper.fromAlert(alert))
          .toList();
    } catch (e) {
      debugPrint('Repository error fetching alerts: $e');
      rethrow;
    }
  }

  @override
  Future<List<ActivityLogItem>> getReports({
    String? viewingOperatorId,
  }) async {
    try {
      // Reports are machine-based, not user-based
      final reports = await ReportService.fetchReports();
      
      // Transform to UI models
      return reports
          .map((report) => ActivityPresentationMapper.fromReport(report))
          .toList();
    } catch (e) {
      debugPrint('Repository error fetching reports: $e');
      rethrow;
    }
  }

  @override
  Future<List<ActivityLogItem>> getCyclesRecom({
    String? viewingOperatorId,
  }) async {
    try {
      final effectiveUserId = _getEffectiveUserId(viewingOperatorId);
      
      // Fetch from service (returns data models)
      final cycles = await CycleService.fetchCyclesRecom(effectiveUserId);
      
      // Transform to UI models
      return cycles
          .map((cycle) => ActivityPresentationMapper.fromCycleRecommendation(cycle))
          .toList();
    } catch (e) {
      debugPrint('Repository error fetching cycles: $e');
      rethrow;
    }
  }

  @override
  Future<List<ActivityLogItem>> getAllActivities({
    String? viewingOperatorId,
  }) async {
    try {
      // Fetch all collections in parallel
      final results = await Future.wait([
        getSubstrates(viewingOperatorId: viewingOperatorId),
        getAlerts(viewingOperatorId: viewingOperatorId),
        getCyclesRecom(viewingOperatorId: viewingOperatorId),
        getReports(viewingOperatorId: viewingOperatorId),
      ]);

      // Combine all lists
      final allActivities = <ActivityLogItem>[
        ...results[0], // substrates
        ...results[1], // alerts
        ...results[2], // cycles
        ...results[3], // reports
      ];

      // Sort by timestamp descending
      allActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      debugPrint(
        '✅ Repository: Fetched ${allActivities.length} total activities',
      );
      debugPrint('   - ${results[0].length} substrates');
      debugPrint('   - ${results[1].length} alerts');
      debugPrint('   - ${results[2].length} cycles');
      debugPrint('   - ${results[3].length} reports');

      return allActivities;
    } catch (e) {
      debugPrint('❌ Repository error fetching all activities: $e');
      rethrow;
    }
  }
}