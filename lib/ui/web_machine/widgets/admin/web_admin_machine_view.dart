// lib/ui/machine_management/widgets/admin/web_admin_machine_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/sess_service.dart';
import '../../../../data/models/machine_model.dart';
import '../../../machine_management/view_model/admin_machine_notifier.dart';
import 'web_add_machine_modal.dart';
import 'web_edit_machine_modal.dart';
import 'web_machine_date_filter_widget.dart';
import 'web_machine_details_view.dart';
import '../admin/web_machine_stat_card.dart';
import '../admin/web_machine_pagination_button.dart';
import '../admin/web_machine_table_row.dart';
import '../admin/web_machine_empty_state.dart';




class WebAdminMachineView extends ConsumerStatefulWidget {
  const WebAdminMachineView({super.key});

  @override
  ConsumerState<WebAdminMachineView> createState() => _WebAdminMachineViewState();
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
  final int _itemsPerPage = 10;

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

  void _showCalendar() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(14),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 700),
          child: MachineDateFilterWidget(
            initialSelectedDate: _selectedDateFilter,
            onDateSelected: (selectedDate) {
              setState(() {
                _selectedDateFilter = selectedDate;
                _currentPage = 1;
              });
            },
            onClose: () {},
          ),
        ),
      ),
    );
  }

  int _getActiveCount(List<MachineModel> machines) {
    return machines.where((m) => !m.isArchived).length;
  }

  int _getInactiveCount(List<MachineModel> machines) {
    return machines.where((m) => m.isArchived).length;
  }

  int _getArcCount(List<MachineModel> machines) {
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
      final matchesSearch = m.machineName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.machineId.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Active' && !m.isArchived) ||
          (_statusFilter == 'Inactive' && m.isArchived) ||
          (_statusFilter == 'Archived' && m.isArchived);

      bool matchesDate = true;
      if (_selectedDateFilter != null) {
        final machineDate = DateTime(m.dateCreated.year, m.dateCreated.month, m.dateCreated.day);
        final filterDate = DateTime(_selectedDateFilter!.year, _selectedDateFilter!.month, _selectedDateFilter!.day);
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
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;

    if (startIndex >= machines.length) return [];
    if (endIndex > machines.length) return machines.sublist(startIndex);

    return machines.sublist(startIndex, endIndex);
  }

  int _getTotalPages(int totalItems) {
    return (totalItems / _itemsPerPage).ceil();
  }

  List<Widget> _buildPageNumbers(int totalPages) {
    final List<Widget> pages = [];

    for (int i = 1; i <= 5 && i <= totalPages; i++) {
      pages.add(MachinePaginationButton(
        label: i.toString(),
        isActive: i == _currentPage,
        onPressed: () {
          setState(() => _currentPage = i);
        },
        enabled: true,
      ));
    }

    return pages;
  }

  Widget _buildColumnHeader(String text, {bool sortable = false}) {
    final isCurrentSort = _sortColumn == text ||
        (_sortColumn == 'ID' && text == 'Machine ID') ||
        (_sortColumn == 'Created' && text == 'Created');

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isCurrentSort ? const Color(0xFF3B82F6) : const Color(0xFF6B7280),
            letterSpacing: 0.5,
          ),
        ),
        if (sortable) ...[
          const SizedBox(width: 4),
          Icon(
            isCurrentSort
                ? (_ascending ? Icons.arrow_upward : Icons.arrow_downward)
                : Icons.unfold_more,
            size: 16,
            color: isCurrentSort ? const Color(0xFF3B82F6) : const Color(0xFF9CA3AF),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusFilterHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _statusFilter != 'All'
                ? const Color(0xFF3B82F6)
                : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.filter_alt,
            size: 16,
            color: _statusFilter != 'All'
                ? const Color(0xFF3B82F6)
                : const Color(0xFF6B7280),
          ),
          onSelected: (value) {
            setState(() {
              _statusFilter = value;
              _currentPage = 1;
            });
          },
          itemBuilder: (context) {
            return ['All', 'Active', 'Inactive', 'Archived']
                .map((status) => PopupMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          if (_statusFilter == status)
                            const Icon(
                              Icons.check,
                              size: 16,
                              color: Color(0xFF3B82F6),
                            ),
                          if (_statusFilter == status) const SizedBox(width: 8),
                          Text(status),
                        ],
                      ),
                    ))
                .toList();
          },
        ),
      ],
    );
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Archive Machine',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        content: const Text(
          'Are you sure you want to archive this machine?',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(adminMachineProvider.notifier).archiveMachine(
              _teamId!,
              machine.machineId,
            );
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

    if (_isInitializing || _teamId == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF14B8A6)),
        ),
      );
    }

    final allMachines = state.filteredMachines;
    final activeCount = _getActiveCount(allMachines);
    final inactiveCount = _getInactiveCount(allMachines);
    final archivedCount = _getArcCount(allMachines);
    final newCount = _getNewCount(allMachines);
    final filteredMachines = _getFilteredMachines(allMachines);
    final paginatedMachines = _getPaginatedMachines(filteredMachines);
    final totalPages = _getTotalPages(filteredMachines.length);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Statistics Cards
              Row(
                children: [
                  Expanded(
                    child: MachineStatCard(
                      title: 'Active Machines',
                      count: activeCount,
                      percentage: '+25%',
                      subtitle: 'activated machines this month',
                      icon: Icons.settings,
                      iconColor: const Color(0xFF10B981),
                      iconBgColor: const Color(0xFFD1FAE5),
                      isPositive: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MachineStatCard(
                      title: 'Inactive Machines',
                      count: inactiveCount,
                      percentage: '+25%',
                      subtitle: 'disabled machines this month',
                      icon: Icons.settings,
                      iconColor: const Color(0xFFF59E0B),
                      iconBgColor: const Color(0xFFFEF3C7),
                      isPositive: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MachineStatCard(
                      title: 'Archived Machines',
                      count: archivedCount,
                      percentage: '-10%',
                      subtitle: 'archived machines this month',
                      icon: Icons.settings,
                      iconColor: const Color(0xFFEF4444),
                      iconBgColor: const Color(0xFFFEE2E2),
                      isPositive: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MachineStatCard(
                      title: 'New Machines',
                      count: newCount,
                      percentage: '-10%',
                      subtitle: 'new machines this month',
                      icon: Icons.settings,
                      iconColor: const Color(0xFF3B82F6),
                      iconBgColor: const Color(0xFFDBEAFE),
                      isPositive: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Machine List Container
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.03 * 255).toInt()),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header with Search and Add Button
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const Text(
                              'Machine List',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const Spacer(),
                            // Calendar Button
                            IconButton(
                              onPressed: _showCalendar,
                              icon: Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                                color: _selectedDateFilter != null
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF6B7280),
                              ),
                              style: IconButton.styleFrom(
                                side: BorderSide(
                                  color: _selectedDateFilter != null
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFE5E7EB),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Search Bar
                            Container(
                              width: 300,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                    _currentPage = 1;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Search...',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 20,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Add Machine Button
                            ElevatedButton(
                              onPressed: _showAddMachineModal,
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
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE5E7EB)),

                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF9FAFB),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () => _applySortAndFilter(column: 'ID'),
                                child: _buildColumnHeader('Machine ID', sortable: true),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: GestureDetector(
                                onTap: () => _applySortAndFilter(column: 'Name'),
                                child: _buildColumnHeader('Name', sortable: true),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () => _applySortAndFilter(column: 'Created'),
                                child: _buildColumnHeader('Created', sortable: true),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildStatusFilterHeader(),
                            ),
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: _buildColumnHeader('Actions', sortable: false),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Table Body
                      Expanded(
                        child: paginatedMachines.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: MachineEmptyState(),
                              )
                            : Scrollbar(
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: paginatedMachines
                                        .map((machine) => Column(
                                              children: [
                                                MachineTableRow(
                                                  machine: machine,
                                                  onEdit: () => _showEditDialog(machine),
                                                  onView: () => _handleViewMachine(machine),
                                                ),
                                                const Divider(
                                                  height: 1,
                                                  color: Color(0xFFE5E7EB),
                                                ),
                                              ],
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ),
                      ),

                      // Pagination
                      if (filteredMachines.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Color(0xFFE5E7EB)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MachinePaginationButton(
                                label: 'Back',
                                icon: Icons.chevron_left,
                                onPressed: () {
                                  if (_currentPage > 1) {
                                    setState(() => _currentPage--);
                                  }
                                },
                                enabled: _currentPage > 1,
                              ),
                              const SizedBox(width: 8),
                              ..._buildPageNumbers(totalPages),
                              const SizedBox(width: 8),
                              MachinePaginationButton(
                                label: 'Next',
                                icon: Icons.chevron_right,
                                iconRight: true,
                                onPressed: () {
                                  if (_currentPage < totalPages) {
                                    setState(() => _currentPage++);
                                  }
                                },
                                enabled: _currentPage < totalPages,
                              ),
                            ],
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