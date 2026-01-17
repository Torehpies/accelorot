import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/providers/operator_providers.dart';
import '../../../data/providers/machine_providers.dart';
import '../../../data/providers/profile_providers.dart';
import '../../../data/providers/report_providers.dart';
import '../../../data/models/operator_model.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/models/report.dart';

/// STATE
class AdminHomeState {
  final List<OperatorModel> operators;
  final List<MachineModel> machines;
  final List<Report> reports;
  final bool isLoading;
  final Object? error;

  const AdminHomeState({
    this.operators = const [],
    this.machines = const [],
    this.reports = const [],
    this.isLoading = false,
    this.error,
  });

  AdminHomeState copyWith({
    List<OperatorModel>? operators,
    List<MachineModel>? machines,
    List<Report>? reports,
    bool? isLoading,
    Object? error,
  }) {
    return AdminHomeState(
      operators: operators ?? this.operators,
      machines: machines ?? this.machines,
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  int get totalOperators => operators.length;
  int get totalMachines => machines.length;
  int get totalReports => reports.length;
  
  int get activeOperators => operators.where((o) => !o.isArchived).length;
  int get archivedOperators => operators.where((o) => o.isArchived).length;
  int get activeMachines => machines.where((m) => !m.isArchived).length;
  int get archivedMachines => machines.where((m) => m.isArchived).length;

  List<OperatorModel> get recentOperators => operators.take(7).toList();
  List<MachineModel> get recentMachines => machines.take(7).toList();

  // Growth rates (placeholder - calculate based on historical data if available)
  double get operatorGrowthRate => totalOperators > 0 ? 12.5 : 0.0;
  double get machineGrowthRate => totalMachines > 0 ? 8.3 : 0.0;
  double get reportGrowthRate => totalReports > 0 ? 15.7 : 0.0;

  // Activity data for chart (last 7 days)
  List<Map<String, dynamic>> get activities {
    final now = DateTime.now();
    final last7Days = List.generate(7, (index) {
      final day = now.subtract(Duration(days: 6 - index));
      final dayReports = reports.where((r) {
        return r.createdAt.year == day.year &&
               r.createdAt.month == day.month &&
               r.createdAt.day == day.day;
      }).length;
      
      return {
        'day': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1],
        'count': dayReports,
      };
    });
    return last7Days;
  }

  // Report status breakdown
  Map<String, int> get reportStatus {
    final statusMap = <String, int>{
      'OPEN': 0,
      'ON HOLD': 0,
      'IN PROGRESS': 0,
    };
    
    for (var report in reports) {
      final status = report.status.toLowerCase();
      if (status == 'open' || status == 'pending') {
        statusMap['OPEN'] = (statusMap['OPEN'] ?? 0) + 1;
      } else if (status == 'on_hold' || status == 'on hold' || status == 'onhold' || status == 'paused') {
        statusMap['ON HOLD'] = (statusMap['ON HOLD'] ?? 0) + 1;
      } else if (status == 'in_progress' || status == 'in progress' || status == 'inprogress' || status == 'active') {
        statusMap['IN PROGRESS'] = (statusMap['IN PROGRESS'] ?? 0) + 1;
      }
    }
    return statusMap;
  }

  // Recent activities for table
  List<Map<String, String>> get recentActivities {
    final recent = reports.take(5).map((report) {
      String icon = 'clipboard';
      if (report.priority.toLowerCase() == 'high' || report.priority.toLowerCase() == 'critical') {
        icon = 'alert';
      } else if (report.status.toLowerCase() == 'closed' || report.status.toLowerCase() == 'resolved') {
        icon = 'check';
      }

      return {
        'icon': icon,
        'description': report.description,
        'username': report.userName,
        'category': report.reportType,
        'status': report.statusLabel,
        'date': '${report.createdAt.month}/${report.createdAt.day}/${report.createdAt.year}',
      };
    }).toList();
    
    return recent;
  }
}

/// PROVIDER
final adminHomeProvider = AsyncNotifierProvider<AdminHomeNotifier, AdminHomeState>(
  AdminHomeNotifier.new,
);

/// NOTIFIER
class AdminHomeNotifier extends AsyncNotifier<AdminHomeState> {
  @override
  Future<AdminHomeState> build() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId == null) {
      return const AdminHomeState();
    }

    try {
      // Fetch user profile to get teamId
      final profile = await ref.read(profileRepositoryProvider).getProfileByUid(userId);
    
      final teamId = profile?.teamId;
      
      if (teamId == null) {
        return const AdminHomeState();
      }

      final operators = await ref.read(operatorRepositoryProvider).getOperators(teamId);
      final machines = await ref.read(machineRepositoryProvider).getMachinesByTeam(teamId);
      final reports = await ref.read(reportRepositoryProvider).getReportsByTeam(teamId);

      return AdminHomeState(
        operators: operators,
        machines: machines,
        reports: reports,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    if (userId == null) {
      state = const AsyncValue.data(AdminHomeState());
      return;
    }

    state = const AsyncValue.loading();
    try {
      // Fetch user profile to get teamId
      final profile = await ref.read(profileRepositoryProvider).getProfileByUid(userId);
      final teamId = profile?.teamId;
      
      if (teamId == null) {
        // User not assigned to a team yet
        state = const AsyncValue.data(AdminHomeState());
        return;
      }

      final operators = await ref.read(operatorRepositoryProvider).getOperators(teamId);
      final machines = await ref.read(machineRepositoryProvider).getMachinesByTeam(teamId);
      final reports = await ref.read(reportRepositoryProvider).getReportsByTeam(teamId);

      state = AsyncValue.data(AdminHomeState(
        operators: operators,
        machines: machines,
        reports: reports,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void refresh() => loadData();
}