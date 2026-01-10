// lib/ui/machine_management/services/machine_filter_service.dart

import '../../../data/models/machine_model.dart';
import '../../activity_logs/models/activity_common.dart';

class FilterResult {
  final List<MachineModel> filteredMachines;

  const FilterResult({
    required this.filteredMachines,
  });
}

class MachineFilterService {
  /// Apply all filters: status, date, search, and sorting
  FilterResult applyAllFilters({
    required List<MachineModel> machines,
    required MachineStatusFilter selectedStatusFilter,
    required DateFilterRange dateFilter,
    required String searchQuery,
    String? sortColumn,
    bool sortAscending = true,
  }) {
    var filtered = machines;

    // 1. Apply status filter
    filtered = _applyStatusFilter(filtered, selectedStatusFilter);

    // 2. Apply date filter
    filtered = _applyDateFilter(filtered, dateFilter);

    // 3. Apply search query
    filtered = _applySearchFilter(filtered, searchQuery);

    // 4. Apply sorting
    if (sortColumn != null) {
      filtered = _applySorting(filtered, sortColumn, sortAscending);
    }

    return FilterResult(filteredMachines: filtered);
  }

  /// Filter by machine status
  List<MachineModel> _applyStatusFilter(
    List<MachineModel> machines,
    MachineStatusFilter filter,
  ) {
    final status = filter.toStatus();
    if (status == null) {
      return machines; // 'All' filter
    }
    return machines.where((m) => m.status == status).toList();
  }

  List<MachineModel> _applyDateFilter(
    List<MachineModel> machines,
    DateFilterRange dateFilter,
  ) {
    if (!dateFilter.isActive) {
      return machines;
    }

    return machines.where((m) {
      // Strip time component - compare dates only
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

      // Inclusive start, exclusive end: [startDate, endDate)
      return !machineDate.isBefore(filterStartDate) && 
             machineDate.isBefore(filterEndDate);
    }).toList();
  }

  /// Filter by search query (machine ID or name)
  List<MachineModel> _applySearchFilter(
    List<MachineModel> machines,
    String query,
  ) {
    if (query.isEmpty) {
      return machines;
    }

    final lowerQuery = query.toLowerCase();
    return machines.where((m) {
      return m.machineId.toLowerCase().contains(lowerQuery) ||
             m.machineName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Sort machines by column
  List<MachineModel> _applySorting(
    List<MachineModel> machines,
    String column,
    bool ascending,
  ) {
    final sorted = List<MachineModel>.from(machines);

    switch (column) {
      case 'machineId':
        sorted.sort((a, b) => a.machineId.compareTo(b.machineId));
        break;
      case 'name':
        sorted.sort((a, b) => a.machineName.compareTo(b.machineName));
        break;
      case 'date':
        sorted.sort((a, b) => a.dateCreated.compareTo(b.dateCreated));
        break;
      default:
        return sorted;
    }

    return ascending ? sorted : sorted.reversed.toList();
  }
}