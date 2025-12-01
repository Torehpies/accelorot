// lib/data/repositories/activity_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../../ui/activity_logs/models/activity_log_item.dart';
import '../../ui/activity_logs/mappers/activity_presentation_mapper.dart';
import '../services/contracts/substrate_service.dart';
import '../services/contracts/alert_service.dart';
import '../services/contracts/report_service.dart';
import '../services/contracts/cycle_service.dart';
import '../services/contracts/batch_service.dart';

// ===== ABSTRACT INTERFACE =====

/// Abstract interface for activity data operations
abstract class ActivityRepository {
  Future<bool> isUserLoggedIn();
  Future<List<ActivityLogItem>> getSubstrates();
  Future<List<ActivityLogItem>> getAlerts();
  Future<List<ActivityLogItem>> getReports();
  Future<List<ActivityLogItem>> getCyclesRecom();
  Future<List<ActivityLogItem>> getAllActivities();
  Future<void> addSubstrate(Map<String, dynamic> data);
}

// ===== FIRESTORE IMPLEMENTATION =====

/// Orchestrates services and transforms data to UI models
class ActivityLogsRepository implements ActivityRepository {
  final SubstrateService _substrateService;
  final AlertService _alertService;
  final ReportService _reportService;
  final CycleService _cycleService;
  final BatchService _batchService;
  final FirebaseAuth _auth;

  ActivityLogsRepository({
    required SubstrateService substrateService,
    required AlertService alertService,
    required ReportService reportService,
    required CycleService cycleService,
    required BatchService batchService,
    FirebaseAuth? auth,
  })  : _substrateService = substrateService,
        _alertService = alertService,
        _reportService = reportService,
        _cycleService = cycleService,
        _batchService = batchService,
        _auth = auth ?? FirebaseAuth.instance;

  // ===== USER MANAGEMENT =====

  String _getCurrentUserId() {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      throw Exception('User not authenticated');
    }
    return userId;
  }

  Future<String> _getTeamId(String userId) async {
    final teamId = await _batchService.getUserTeamId(userId);
    if (teamId == null || teamId.isEmpty) {
      throw Exception('User is not part of any team');
    }
    return teamId;
  }

  @override
  Future<bool> isUserLoggedIn() async {
    final userId = _auth.currentUser?.uid;
    return userId != null && userId.isNotEmpty;
  }

  // ===== FETCH METHODS =====

  @override
  Future<List<ActivityLogItem>> getSubstrates() async {
    final userId = _getCurrentUserId();
    final teamId = await _getTeamId(userId);

    final substrates = await _substrateService.fetchTeamSubstrates(teamId);

    return substrates
        .map((substrate) => ActivityPresentationMapper.fromSubstrate(substrate))
        .toList();
  }

  @override
  Future<List<ActivityLogItem>> getAlerts() async {
    final userId = _getCurrentUserId();
    final teamId = await _getTeamId(userId);

    final alerts = await _alertService.fetchTeamAlerts(teamId);

    return alerts
        .map((alert) => ActivityPresentationMapper.fromAlert(alert))
        .toList();
  }

  @override
  Future<List<ActivityLogItem>> getReports() async {
    final userId = _getCurrentUserId();
    final teamId = await _getTeamId(userId);

    final reports = await _reportService.fetchTeamReports(teamId);

    return reports
        .map((report) => ActivityPresentationMapper.fromReport(report))
        .toList();
  }

  @override
  Future<List<ActivityLogItem>> getCyclesRecom() async {
    final userId = _getCurrentUserId();
    final teamId = await _getTeamId(userId);

    final cycles = await _cycleService.fetchTeamCycles(teamId);

    return cycles
        .map(
          (cycle) => ActivityPresentationMapper.fromCycleRecommendation(cycle),
        )
        .toList();
  }

  @override
  Future<List<ActivityLogItem>> getAllActivities() async {
    // ✅ FIXED: Reuse existing methods instead of duplicating logic
    final results = await Future.wait([
      getSubstrates(),
      getAlerts(),
      getCyclesRecom(),
      getReports(),
    ]);

    // Flatten list of lists into single list
    final allActivities = results.expand((list) => list).toList();

    // Sort by timestamp descending (newest first)
    allActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return allActivities;
  }

  // ===== CREATE OPERATIONS =====

  @override
  Future<void> addSubstrate(Map<String, dynamic> data) async {
    final userId = _getCurrentUserId();
    final machineId = data['machineId'];

    if (machineId == null || machineId.toString().isEmpty) {
      throw Exception('Machine ID is required');
    }

    String batchId =
        await _batchService.getBatchId(userId, machineId) ??
        await _batchService.createBatch(userId, machineId, 1);

    await _substrateService.addSubstrate(data, batchId);

    await _batchService.updateBatchTimestamp(batchId);
  }
}