// lib/data/repositories/activity_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../ui/activity_logs/models/activity_log_item.dart';
import '../../ui/activity_logs/mappers/activity_presentation_mapper.dart';
import '../services/firebase/activity_logs/substrate_service.dart';
import '../services/firebase/activity_logs/alert_service.dart';
import '../services/firebase/activity_logs/report_service.dart';
import '../services/firebase/activity_logs/cycle_service.dart';

// ===== ABSTRACT INTERFACE =====

/// Abstract interface for activity data operations
/// Implementations should handle user authentication internally
abstract class ActivityRepository {

  Future<bool> isUserLoggedIn();

  Future<List<ActivityLogItem>> getSubstrates();
  Future<List<ActivityLogItem>> getAlerts();
  Future<List<ActivityLogItem>> getReports();
  Future<List<ActivityLogItem>> getCyclesRecom();
  Future<List<ActivityLogItem>> getAllActivities();
}

// ===== FIRESTORE IMPLEMENTATION =====

/// Orchestrates services and transforms data to UI models
class ActivityLogsRepository implements ActivityRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== USER MANAGEMENT =====

  String _getCurrentUserId() {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated');
    }
    return userId;
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      final userId = _auth.currentUser?.uid;
      return userId != null && userId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ===== FETCH METHODS - ORCHESTRATION + TRANSFORMATION =====

  @override
  Future<List<ActivityLogItem>> getSubstrates() async {
    try {
      final userId = _getCurrentUserId();
      
      // Fetch from service (returns data models)
      final substrates = await SubstrateService.fetchSubstrates(userId);
      
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
  Future<List<ActivityLogItem>> getAlerts() async {
    try {
      final userId = _getCurrentUserId();
      
      // Fetch from service (returns data models)
      final alerts = await AlertService.fetchAlerts(userId);
      
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
  Future<List<ActivityLogItem>> getReports() async {
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
  Future<List<ActivityLogItem>> getCyclesRecom() async {
    try {
      final userId = _getCurrentUserId();
      
      // Fetch from service (returns data models)
      final cycles = await CycleService.fetchCyclesRecom(userId);
      
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
  Future<List<ActivityLogItem>> getAllActivities() async {
    try {
      // Fetch all collections in parallel
      final results = await Future.wait([
        getSubstrates(),
        getAlerts(),
        getCyclesRecom(),
        getReports(),
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