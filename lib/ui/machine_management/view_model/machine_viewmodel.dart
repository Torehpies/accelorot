// lib/ui/machine_management/view_model/machine_viewmodel.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/providers/machine_providers.dart';
import '../services/machine_aggregator_service.dart';
import '../services/machine_filter_service.dart';
import '../models/machine_state.dart';
import '../../activity_logs/models/activity_common.dart';

part 'machine_viewmodel.g.dart';

@riverpod
MachineAggregatorService machineAggregatorService(Ref ref) {
  final repository = ref.watch(machineRepositoryProvider);
  return MachineAggregatorService(machineRepo: repository);
}

@riverpod
class MachineViewModel extends _$MachineViewModel {
  late final MachineAggregatorService _aggregator;
  late final MachineFilterService _filterService;

  String? _currentTeamId;

  @override
  MachineState build() {
    _aggregator = ref.read(machineAggregatorServiceProvider);
    _filterService = MachineFilterService();
    Future.microtask(() => _initialize());

    return const MachineState();
  }

  // ===== INITIALIZATION =====

  Future<void> _initialize() async {
    state = state.copyWith(status: LoadingStatus.loading, errorMessage: null);

    try {
      final isLoggedIn = await _aggregator.isUserLoggedIn();

      if (!isLoggedIn) {
        state = state.copyWith(
          status: LoadingStatus.success,
          isLoggedIn: false,
        );
        return;
      }

      final teamId = FirebaseAuth.instance.currentUser?.uid;

      if (teamId == null) {
        state = state.copyWith(
          status: LoadingStatus.error,
          errorMessage: 'Unable to get team ID',
        );
        return;
      }

      _currentTeamId = teamId;
      state = state.copyWith(isLoggedIn: true);

      await loadMachines(teamId);
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage:
            'Failed to load: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    }
  }

  // ===== DATA LOADING =====

  Future<void> loadMachines(String teamId) async {
    _currentTeamId = teamId;

    try {
      state = state.copyWith(status: LoadingStatus.loading);

      final machines = await _aggregator.getMachines(teamId);

      state = state.copyWith(machines: machines, status: LoadingStatus.success);

      // Apply filters to the newly loaded data
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    if (_currentTeamId == null) return;
    await loadMachines(_currentTeamId!);
  }

  // ===== WEB FILTER HANDLERS =====

  void onStatusFilterChanged(MachineStatusFilter filter) {
    state = state.copyWith(selectedStatusFilter: filter, currentPage: 1);
    _applyFilters();
  }

  void onDateFilterChanged(DateFilterRange dateFilter) {
    state = state.copyWith(dateFilter: dateFilter, currentPage: 1);
    _applyFilters();
  }

  void clearDateFilter() {
    state = state.copyWith(
      dateFilter: const DateFilterRange(type: DateFilterType.none),
      currentPage: 1,
    );
    _applyFilters();
  }

  void onSearchChanged(String query) {
    state = state.copyWith(searchQuery: query, currentPage: 1);
    _applyFilters();
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '', currentPage: 1);
    _applyFilters();
  }

  // ===== WEB SORTING HANDLERS =====

  void onSort(String column) {
    final isAscending = state.sortColumn == column
        ? !state.sortAscending
        : true;

    state = state.copyWith(sortColumn: column, sortAscending: isAscending);

    _applyFilters();
  }

  // ===== WEB PAGINATION HANDLERS =====

  void onPageChanged(int page) {
    state = state.copyWith(currentPage: page);
  }

  void onItemsPerPageChanged(int itemsPerPage) {
    state = state.copyWith(itemsPerPage: itemsPerPage, currentPage: 1);
  }

  // ===== FILTERING LOGIC =====

  /// Apply all filters using the filter service
  void _applyFilters() {
    final result = _filterService.applyAllFilters(
      machines: state.machines,
      selectedStatusFilter: state.selectedStatusFilter,
      dateFilter: state.dateFilter,
      searchQuery: state.searchQuery,
      sortColumn: state.sortColumn,
      sortAscending: state.sortAscending,
    );

    state = state.copyWith(filteredMachines: result.filteredMachines);
  }

  // ===== STATS CALCULATIONS =====

  /// Get machine stats with month-over-month change percentage
  Map<String, Map<String, dynamic>> getMachineStatsWithChange() {
    final now = DateTime.now();

    // Current month: from start of this month to now
    final currentMonthStart = DateTime(now.year, now.month, 1);
    final currentMonthEnd = now;

    // Previous month: full month
    final previousMonthStart = DateTime(now.year, now.month - 1, 1);
    final previousMonthEnd = DateTime(
      now.year,
      now.month,
      1,
    ).subtract(const Duration(microseconds: 1));

    // Get ALL-TIME counts (for display)
    final allTimeStats = _getAllTimeStats();

    // Get counts for current month (for comparison)
    final currentStats = _getStatsForDateRange(
      currentMonthStart,
      currentMonthEnd,
    );

    // Get counts for previous month (for comparison)
    final previousStats = _getStatsForDateRange(
      previousMonthStart,
      previousMonthEnd,
    );

    return {
      'total': _buildChangeData(
        allTimeStats['total']!,
        currentStats['total']!,
        previousStats['total']!,
        'machines created',
      ),
      'active': _buildChangeData(
        allTimeStats['active']!,
        currentStats['active']!,
        previousStats['active']!,
        'activated',
      ),
      'archived': _buildChangeData(
        allTimeStats['archived']!,
        currentStats['archived']!,
        previousStats['archived']!,
        'archived',
      ),
      'suspended': _buildChangeData(
        allTimeStats['suspended']!,
        currentStats['suspended']!,
        previousStats['suspended']!,
        'suspended',
      ),
    };
  }

  /// Helper: Get all-time stats (for display counts)
  Map<String, int> _getAllTimeStats() {
    final total = state.machines.length;

    final active = state.machines
        .where((m) => m.status == MachineStatus.active && !m.isArchived)
        .length;

    final archived = state.machines.where((m) => m.isArchived).length;

    final suspended = state.machines
        .where(
          (m) => m.status == MachineStatus.underMaintenance && !m.isArchived,
        )
        .length;

    return {
      'total': total,
      'active': active,
      'archived': archived,
      'suspended': suspended,
    };
  }

  /// Helper: Get stats for a specific date range
  Map<String, int> _getStatsForDateRange(DateTime start, DateTime end) {
    // Total: Count machines CREATED in this range
    final newMachines = state.machines.where((m) {
      return m.dateCreated.isAfter(start) && m.dateCreated.isBefore(end);
    }).length;

    // Active: Count machines that are currently active AND were modified in range
    final activeChanged = state.machines.where((m) {
      final wasModified =
          m.lastModified != null &&
          m.lastModified!.isAfter(start) &&
          m.lastModified!.isBefore(end);
      return m.status == MachineStatus.active && !m.isArchived && wasModified;
    }).length;

    // Archived: Count machines that are archived AND were modified in range
    final archivedChanged = state.machines.where((m) {
      final wasModified =
          m.lastModified != null &&
          m.lastModified!.isAfter(start) &&
          m.lastModified!.isBefore(end);
      return m.isArchived && wasModified;
    }).length;

    // Suspended: Count machines under maintenance AND were modified in range
    final suspendedChanged = state.machines.where((m) {
      final wasModified =
          m.lastModified != null &&
          m.lastModified!.isAfter(start) &&
          m.lastModified!.isBefore(end);
      return m.status == MachineStatus.underMaintenance &&
          !m.isArchived &&
          wasModified;
    }).length;

    return {
      'total': newMachines,
      'active': activeChanged,
      'archived': archivedChanged,
      'suspended': suspendedChanged,
    };
  }

  /// Helper: Build change data with percentage and positive/negative indicator
  Map<String, dynamic> _buildChangeData(
    int allTimeCount,
    int currentMonthCount,
    int previousMonthCount,
    String changeType,
  ) {
    String changeText;
    bool isPositive = true;

    if (previousMonthCount == 0 && currentMonthCount > 0) {
      // New this month
      changeText = 'New';
      isPositive = true;
    } else if (previousMonthCount == 0 && currentMonthCount == 0) {
      // No data yet
      changeText = 'No log yet';
      isPositive = true; // Neutral
    } else {
      // Calculate percentage change (current month vs previous month)
      final percentageChange =
          ((currentMonthCount - previousMonthCount) / previousMonthCount * 100)
              .round();
      isPositive = percentageChange >= 0;
      final sign = isPositive ? '+' : '';
      changeText = '$sign$percentageChange%';
    }

    return {
      'count': allTimeCount,
      'change': changeText,
      'isPositive': isPositive,
      'changeType': changeType, // "new machines" or "status changed"
    };
  }

  // ===== MACHINE OPERATIONS =====

  Future<void> addMachine({
    required String machineName,
    required String machineId,
    required List<String> assignedUserIds,
  }) async {
    if (_currentTeamId == null) {
      throw Exception('Team ID not available');
    }

    try {
      final exists = await _aggregator.checkMachineExists(machineId);
      if (exists) {
        throw Exception('Machine ID "$machineId" already exists');
      }

      final request = CreateMachineRequest(
        machineId: machineId,
        machineName: machineName,
        teamId: _currentTeamId!,
        assignedUserIds: assignedUserIds,
        status: MachineStatus.active,
      );

      await _aggregator.createMachine(request);
      await Future.delayed(const Duration(milliseconds: 1000));
      await refresh();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: 'Failed to add machine: $e',
      );
      rethrow;
    }
  }

  Future<void> updateMachine({
    required String machineId,
    String? machineName,
    MachineStatus? status,
    List<String>? assignedUserIds,
  }) async {
    if (_currentTeamId == null) {
      throw Exception('Team ID not available');
    }

    try {
      final request = UpdateMachineRequest(
        machineId: machineId,
        machineName: machineName,
        status: status,
        assignedUserIds: assignedUserIds,
      );

      await _aggregator.updateMachine(request);
      await Future.delayed(const Duration(milliseconds: 1000));
      await refresh();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: 'Failed to update machine: $e',
      );
      rethrow;
    }
  }

  Future<void> archiveMachine(String machineId) async {
    if (_currentTeamId == null) {
      throw Exception('Team ID not available');
    }

    try {
      await _aggregator.archiveMachine(machineId);
      await Future.delayed(const Duration(milliseconds: 300));
      await refresh();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: 'Failed to archive machine: $e',
      );
      rethrow;
    }
  }

  Future<void> restoreMachine(String machineId) async {
    if (_currentTeamId == null) {
      throw Exception('Team ID not available');
    }

    try {
      await _aggregator.restoreMachine(machineId);
      await Future.delayed(const Duration(milliseconds: 300));
      await refresh();
    } catch (e) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: 'Failed to restore machine: $e',
      );
      rethrow;
    }
  }

  Future<bool> machineExists(String machineId) async {
    try {
      return await _aggregator.checkMachineExists(machineId);
    } catch (e) {
      debugPrint('Error checking machine existence: $e');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
