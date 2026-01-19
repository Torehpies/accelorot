// lib/ui/machine_management/models/mobile_machine_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/machine_model.dart';
import '../../activity_logs/models/activity_common.dart';
import '../view_model/mobile_machine_viewmodel.dart';

part 'mobile_machine_state.freezed.dart';

/// State for mobile machine management
@freezed
abstract class MobileMachineState with _$MobileMachineState {
  const factory MobileMachineState({
    // Mobile-specific: Tab filtering
    @Default(MachineFilterTab.all) MachineFilterTab selectedTab,
    
    // Mobile-specific: Load-more pagination
    @Default(5) int displayLimit,
    
    // Shared: Filters
    @Default(DateFilterRange(type: DateFilterType.none)) DateFilterRange dateFilter,
    @Default('') String searchQuery,
    @Default('name') String selectedSort,
    
    // Data
    @Default([]) List<MachineModel> machines,
    
    // UI state
    @Default(LoadingStatus.initial) LoadingStatus status,
    String? errorMessage,
  }) = _MobileMachineState;

  const MobileMachineState._();

  // ===== COMPUTED PROPERTIES =====

  List<MachineModel> get filteredMachines {
    var filtered = machines;
    filtered = _filterByTab(filtered);
    filtered = _filterByDate(filtered);
    filtered = _filterBySearch(filtered);
    filtered = _sortMachines(filtered);
    return filtered;
  }

  List<MachineModel> get displayedMachines {
    return filteredMachines.take(displayLimit).toList();
  }

  bool get hasMoreToLoad {
    return displayedMachines.length < filteredMachines.length;
  }

  int get remainingCount {
    return filteredMachines.length - displayedMachines.length;
  }

  int get activeFilterCount {
    int count = 0;
    if (dateFilter.isActive) count++;
    if (searchQuery.isNotEmpty) count++;
    if (selectedTab != MachineFilterTab.all) count++;
    return count;
  }

  bool get isLoading => status == LoadingStatus.loading;
  bool get hasError => status == LoadingStatus.error;
  bool get isEmpty => filteredMachines.isEmpty && status == LoadingStatus.success;

  // ===== PRIVATE FILTER METHODS =====

  List<MachineModel> _filterByTab(List<MachineModel> machines) {
    switch (selectedTab) {
      case MachineFilterTab.all:
        return machines.where((m) => !m.isArchived).toList();
      case MachineFilterTab.active:
        return machines
            .where((m) => !m.isArchived && m.status == MachineStatus.active)
            .toList();
      case MachineFilterTab.suspended:
        return machines
            .where((m) => !m.isArchived && m.status == MachineStatus.underMaintenance)
            .toList();
      case MachineFilterTab.archived:
        return machines.where((m) => m.isArchived).toList();
    }
  }

  List<MachineModel> _filterByDate(List<MachineModel> machines) {
    if (!dateFilter.isActive) return machines;

    return machines.where((m) {
      final machineDate = DateTime(
        m.dateCreated.year,
        m.dateCreated.month,
        m.dateCreated.day,
      );
      
      final filterStartDate = DateTime(
        dateFilter.startDate!.year,
        dateFilter.startDate!.month,
        dateFilter.startDate!.day,
      );
      
      final filterEndDate = DateTime(
        dateFilter.endDate!.year,
        dateFilter.endDate!.month,
        dateFilter.endDate!.day,
      );

      return !machineDate.isBefore(filterStartDate) && 
             machineDate.isBefore(filterEndDate);
    }).toList();
  }

  List<MachineModel> _filterBySearch(List<MachineModel> machines) {
    if (searchQuery.isEmpty) return machines;

    final query = searchQuery.toLowerCase();
    return machines.where((m) {
      return m.machineName.toLowerCase().contains(query) ||
             m.machineId.toLowerCase().contains(query);
    }).toList();
  }

  List<MachineModel> _sortMachines(List<MachineModel> machines) {
    final sorted = List<MachineModel>.from(machines);

    switch (selectedSort) {
      case 'machineId':
        sorted.sort((a, b) => a.machineId.compareTo(b.machineId));
        break;
      case 'name':
        sorted.sort((a, b) => a.machineName.compareTo(b.machineName));
        break;
      case 'date':
        sorted.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
        break;
    }

    return sorted;
  }
}