// lib/ui/operator_dashboard/view_model/operator_dashboard_viewmodel.dart

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/providers/machine_providers.dart';
import '../../../data/providers/batch_providers.dart';
import '../../../data/providers/statistics_providers.dart';
import '../../../data/providers/substrate_providers.dart';
import '../../../data/providers/cycle_providers.dart';
import '../../machine_management/services/machine_aggregator_service.dart';
import '../models/operator_dashboard_state.dart';
import '../../activity_logs/models/activity_common.dart';

part 'operator_dashboard_viewmodel.g.dart';

// ===== AGGREGATOR SERVICE PROVIDER =====
@riverpod
MachineAggregatorService operatorDashboardAggregatorService(Ref ref) {
  final repository = ref.watch(machineRepositoryProvider);
  return MachineAggregatorService(machineRepo: repository);
}

// ===== OPERATOR DASHBOARD VIEW MODEL =====
@Riverpod(keepAlive: true)
class OperatorDashboardViewModel extends _$OperatorDashboardViewModel {
  late MachineAggregatorService _aggregator;

  @override
  OperatorDashboardState build() {
    _aggregator = ref.read(operatorDashboardAggregatorServiceProvider);
    return const OperatorDashboardState();
  }

  // ===== INITIALIZATION =====

  Future<void> initialize(String teamId) async {
    // If we already have machines loaded successfully, do nothing.
    // This prevents the dashboard from reloading when the user
    // navigates away (tab switch) and comes back.
    if (state.status == LoadingStatus.success && state.machines.isNotEmpty) {
      return;
    }

    state = state.copyWith(status: LoadingStatus.loading, errorMessage: null);

    try {
      final machines = await _aggregator
          .getMachines(teamId)
          .timeout(const Duration(seconds: 10));

      if (!ref.mounted) return;

      await _deepLoad(machines);

      state = state.copyWith(machines: machines, status: LoadingStatus.success);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage:
            'Failed to load: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    }
  }

  Future<void> refresh(String teamId) async {
    try {
      final machines = await _aggregator
          .getMachines(teamId)
          .timeout(const Duration(seconds: 10));

      await _deepLoad(machines);

      state = state.copyWith(machines: machines);
    } catch (e) {
      state = state.copyWith(
        errorMessage:
            'Failed to refresh: ${e.toString().replaceAll('Exception:', '').trim()}',
      );
    }
  }

  /// Per-machine data pre-loading using polling to avoid UI "pop-in"
  /// Safely ensures synchronous rendering without hanging.
  Future<void> _deepLoad(List<MachineModel> machines) async {
    final List<dynamic> subs = [];

    // 1. Kick off providers by temporarily listening
    subs.add(ref.listen(teamCyclesStreamProvider, (prev, next) {}));

    for (final machine in machines) {
      subs.add(
        ref.listen(
          activeBatchForMachineProvider(machine.machineId),
          (prev, next) {},
        ),
      );

      if (machine.currentBatchId != null) {
        subs.add(
          ref.listen(
            latestSensorReadingsProvider(machine.currentBatchId!),
            (prev, next) {},
          ),
        );
        subs.add(
          ref.listen(
            batchSubstratesProvider(machine.currentBatchId!),
            (prev, next) {},
          ),
        );
      }
    }

    // 2. Poll iteratively until everything confirms it has a value, OR we hit 10 seconds.
    bool allLoaded = false;
    int attempts = 0;

    while (!allLoaded && attempts < 100) {
      bool stillLoading = false;

      if (!ref.read(teamCyclesStreamProvider).hasValue) {
        stillLoading = true;
      }

      if (!stillLoading) {
        for (final machine in machines) {
          if (!ref
              .read(activeBatchForMachineProvider(machine.machineId))
              .hasValue) {
            stillLoading = true;
            break;
          }
          if (machine.currentBatchId != null) {
            if (!ref
                .read(latestSensorReadingsProvider(machine.currentBatchId!))
                .hasValue) {
              stillLoading = true;
              break;
            }
            if (!ref
                .read(batchSubstratesProvider(machine.currentBatchId!))
                .hasValue) {
              stillLoading = true;
              break;
            }
          }
        }
      }

      if (!stillLoading) {
        allLoaded = true;
      } else {
        await Future.delayed(const Duration(milliseconds: 100));
        attempts++;
      }
    }

    // 3. Cleanup manual subscriptions so the UI can safely take over
    for (final sub in subs) {
      sub.close();
    }

    if (!allLoaded) {
      debugPrint('Deep Load polling partially timed out after 10 seconds.');
    }
  }

  // ===== STATUS FILTERING =====

  void setDrumFilter(DrumStatusFilter filter) {
    HapticFeedback.selectionClick();
    state = state.copyWith(
      selectedDrumFilter: filter,
      searchQuery: '', // Clear search when switching status
    );
  }

  // ===== DATE FILTERING =====

  void setDateFilter(DateFilterRange dateFilter) {
    HapticFeedback.selectionClick();
    state = state.copyWith(dateFilter: dateFilter);
  }

  void clearDateFilter() {
    state = state.copyWith(
      dateFilter: const DateFilterRange(type: DateFilterType.none),
    );
  }

  // ===== SEARCH FILTERING =====

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  // ===== SORTING =====

  void setSort(String sortBy) {
    state = state.copyWith(selectedSort: sortBy);
  }

  // ===== CLEAR ALL FILTERS =====

  void clearAllFilters() {
    state = state.copyWith(
      selectedDrumFilter: DrumStatusFilter.all,
      dateFilter: const DateFilterRange(type: DateFilterType.none),
      searchQuery: '',
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
