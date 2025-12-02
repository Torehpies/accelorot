// lib/data/repositories/activity_repository.dart

import 'package:firebase_auth/firebase_auth.dart';
import '../../ui/activity_logs/models/activity_log_item.dart';
import '../../ui/activity_logs/mappers/activity_presentation_mapper.dart';
import 'substrate_repository.dart';
import 'alert_repository.dart';
import 'report_repository.dart';
import 'cycle_repository.dart';

/// Repository that aggregates activities from multiple sources
/// and transforms them to UI-ready models
class ActivityRepository {
  final SubstrateRepository _substrateRepo;
  final AlertRepository _alertRepo;
  final ReportRepository _reportRepo;
  final CycleRepository _cycleRepo;
  final FirebaseAuth _auth;

  ActivityRepository({
    required SubstrateRepository substrateRepo,
    required AlertRepository alertRepo,
    required ReportRepository reportRepo,
    required CycleRepository cycleRepo,
    FirebaseAuth? auth,
  })  : _substrateRepo = substrateRepo,
        _alertRepo = alertRepo,
        _reportRepo = reportRepo,
        _cycleRepo = cycleRepo,
        _auth = auth ?? FirebaseAuth.instance;

  // ===== USER MANAGEMENT =====

  Future<bool> isUserLoggedIn() async {
    final userId = _auth.currentUser?.uid;
    return userId != null && userId.isNotEmpty;
  }

  // ===== FETCH & TRANSFORM METHODS =====

  Future<List<ActivityLogItem>> getSubstrates() async {
    final substrates = await _substrateRepo.getTeamSubstrates();
    return substrates
        .map((substrate) => ActivityPresentationMapper.fromSubstrate(substrate))
        .toList();
  }

  Future<List<ActivityLogItem>> getAlerts() async {
    final alerts = await _alertRepo.getTeamAlerts();
    return alerts
        .map((alert) => ActivityPresentationMapper.fromAlert(alert))
        .toList();
  }

  Future<List<ActivityLogItem>> getReports() async {
    final reports = await _reportRepo.getTeamReports();
    return reports
        .map((report) => ActivityPresentationMapper.fromReport(report))
        .toList();
  }

  Future<List<ActivityLogItem>> getCyclesRecom() async {
    final cycles = await _cycleRepo.getTeamCycles();
    return cycles
        .map(
          (cycle) => ActivityPresentationMapper.fromCycleRecommendation(cycle),
        )
        .toList();
  }

  Future<List<ActivityLogItem>> getAllActivities() async {
    // Fetch all activity types in parallel
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

  /// Add substrate - delegates to SubstrateRepository
  Future<void> addSubstrate(Map<String, dynamic> data) async {
    await _substrateRepo.addSubstrate(data);
  }
}