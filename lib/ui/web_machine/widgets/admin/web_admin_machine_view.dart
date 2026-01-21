import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/sess_service.dart';
import '../../../../data/models/machine_model.dart';
import '../../../machine_management/view_model/admin_machine_notifier.dart';
import '../../../core/widgets/filters/search_field.dart';
import '../../shared/pagination_table.dart';
import '../../../core/widgets/table/table_container.dart';
import '../../../../ui/web_machine/filters/web_machine_date_filter_widget.dart';
import 'web_add_machine_modal.dart';
import 'web_edit_machine_modal.dart';
import 'web_machine_details_view.dart';
import '../../table/web_machine_table_header.dart';
import '../../table/machine_table_body.dart';
import '../admin/archive_confirmation_dialog.dart';
import '../admin/machine_stats_row.dart';

class WebAdminMachineView extends ConsumerStatefulWidget {
  const WebAdminMachineView({super.key});

  @override
  ConsumerState<WebAdminMachineView> createState() =>
      _WebAdminMachineViewState();
}

class _WebAdminMachineViewState extends ConsumerState<WebAdminMachineView> {
  String? _teamId;
  bool _isInitializing = true;
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _sortColumn = 'ID';
  bool _ascending = true;
  DateTime? _selectedDateFilter;

  // Pagination
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadTeamIdAndInit();
  }

  Future<void> _loadTeamIdAndInit() async {
    try {
      final sessionService = SessionService();
      final userData = await sessionService.getCurrentUserData();
      _teamId = userData?['teamId'] as String?;

      if (_teamId != null && mounted) {
        await ref.read(adminMachineProvider.notifier).initialize(_teamId!);
      }
    } catch (e) {
      debugPrint('Error loading team ID: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  void _showAddMachineModal() {
    if (_teamId == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: WebAddMachineModal(teamId: _teamId!),
        ),
      ),
    );
  }

  int _getActiveCount(List<MachineModel> machines) {
    return machines.where((m) => !m.isArchived).length;
  }

  int _getArchivedCount(List<MachineModel> machines) {
    return machines.where((m) => m.isArchived).length;
  }

  int _getNewCount(List<MachineModel> machines) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    return machines.where((m) => m.dateCreated.isAfter(thirtyDaysAgo)).length;
  }

  void _applySortAndFilter({String? column}) {
    if (column != null) {
      if (_sortColumn == column) {
        setState(() => _ascending = !_ascending);
      } else {
        setState(() {
          _sortColumn = column;
          _ascending = true;
        });
      }
    }
    setState(() => _currentPage = 1);
  }

  List<MachineModel> _getFilteredMachines(List<MachineModel> machines) {
    var filtered = machines.where((m) {
      final matchesSearch =
          m.machineName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.machineId.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus =
          _statusFilter == 'All' ||
          (_statusFilter == 'Active' && !m.isArchived) ||
          (_statusFilter == 'Archived' && m.isArchived);

      bool matchesDate = true;
      if (_selectedDateFilter != null) {
        final machineDate = DateTime(
          m.dateCreated.year,
          m.dateCreated.month,
          m.dateCreated.day,
        );
        final filterDate = DateTime(
          _selectedDateFilter!.year,
          _selectedDateFilter!.month,
          _selectedDateFilter!.day,
        );
        matchesDate = machineDate.isAtSameMomentAs(filterDate);
      }

      return matchesSearch && matchesStatus && matchesDate;
    }).toList();

    filtered.sort((a, b) {
      int cmp;
      switch (_sortColumn) {
        case 'ID':
          cmp = a.machineId.compareTo(b.machineId);
          break;
        case 'Name':
          cmp = a.machineName.compareTo(b.machineName);
          break;
        case 'Created':
          cmp = a.dateCreated.compareTo(b.dateCreated);
          break;
        default:
          cmp = 0;
      }
      return _ascending ? cmp : -cmp;
    });

    return filtered;
  }

  List<MachineModel> _getPaginatedMachines(List<MachineModel> machines) {
    if (machines.isEmpty) return [];
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    if (startIndex >= machines.length) return [];
    if (endIndex > machines.length) return machines.sublist(startIndex);

    return machines.sublist(startIndex, endIndex);
  }

  int _getTotalPages(int totalItems) {
    if (totalItems == 0) return 1;
    return (totalItems / _itemsPerPage).ceil();
  }

  void _showEditDialog(MachineModel machine) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
          child: WebEditMachineModal(machine: machine, teamId: _teamId!),
        ),
      ),
    );
  }

  void _handleViewMachine(MachineModel machine) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: WebMachineDetailsView(
            machine: machine,
            teamId: _teamId!,
            onArchive: () {
              Navigator.pop(context);
              _showArchiveConfirmation(machine);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showArchiveConfirmation(MachineModel machine) async {
    final confirmed = await ArchiveConfirmationDialog.show(context);

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(adminMachineProvider.notifier)
            .archiveMachine(_teamId!, machine.machineId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${machine.machineName} archived successfully'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to archive: $e'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminMachineProvider);

    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF10B981)),
        ),
      );
    }

    final allMachines = state.filteredMachinesByStatus;
    final activeCount = _getActiveCount(allMachines);
    final archivedCount = _getArchivedCount(allMachines);
    final newCount = _getNewCount(allMachines);
    final filteredMachines = _getFilteredMachines(allMachines);
    final paginatedMachines = _getPaginatedMachines(filteredMachines);
    final totalPages = _getTotalPages(filteredMachines.length);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.backgroundBorder,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MachineStatsRow(
                        activeCount: activeCount,
                        archivedCount: archivedCount,
                        newCount: newCount,
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: BaseTableContainer(
                          leftHeaderWidget: const Text(
                            'Machine List',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          rightHeaderWidgets: [
                            WebMachineDateFilter(
                              onDateSelected: (date) {
                                setState(() {
                                  _selectedDateFilter = date;
                                  _currentPage = 1;
                                });
                              },
                              isLoading: state.isLoading,
                            ),
                            SearchField(
                              hintText: 'Search machines...',
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                  _currentPage = 1;
                                });
                              },
                              width: 300,
                              isLoading: state.isLoading,
                            ),
                            ElevatedButton(
                              onPressed: state.isLoading
                                  ? null
                                  : _showAddMachineModal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Add Machine',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          tableHeader: MachineTableHeader(
                            sortColumn: _sortColumn,
                            ascending: _ascending,
                            statusFilter: _statusFilter,
                            onSort: (column) =>
                                _applySortAndFilter(column: column),
                            onStatusChanged: (status) {
                              setState(() {
                                _statusFilter = status;
                                _currentPage = 1;
                              });
                            },
                            isLoading: state.isLoading,
                          ),
                          tableBody: MachineTableBody(
                            items: paginatedMachines,
                            onViewDetails: _handleViewMachine,
                            onEdit: _showEditDialog,
                            isLoading: state.isLoading,
                            isEmpty: filteredMachines.isEmpty,
                            hasNoTeam: _teamId == null,
                          ),
                          paginationWidget: PaginationTable(
                            currentPage: _currentPage,
                            totalPages: totalPages,
                            itemsPerPage: _itemsPerPage,
                            onPageChanged: (page) {
                              setState(() => _currentPage = page);
                            },
                            onItemsPerPageChanged: (value) {
                              setState(() {
                                _itemsPerPage = value;
                                _currentPage = 1;
                              });
                            },
                            isLoading: state.isLoading,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
