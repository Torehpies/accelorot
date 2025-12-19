import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../machine_management/view_model/admin_machine_notifier.dart';
import '../../../../services/sess_service.dart';
import 'web_add_machine_modal.dart';
import 'web_edit_machine_modal.dart';
import '../../../../data/models/machine_model.dart';

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

  int _getInactiveCount(List<MachineModel> machines) {
    return machines.where((m) => m.isArchived).length;
  }

  int _getSuspendedCount(List<MachineModel> machines) {
    return 0;
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
  }

  List<MachineModel> _getFilteredMachines(List<MachineModel> machines) {
    var filtered = machines.where((m) {
      final matchesSearch = m.machineName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.machineId.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Active' && !m.isArchived) ||
          (_statusFilter == 'Inactive' && m.isArchived);

      return matchesSearch && matchesStatus;
    }).toList();

    // Apply sorting
    filtered.sort((a, b) {
      int cmp;
      switch (_sortColumn) {
        case 'ID':
          cmp = a.machineId.compareTo(b.machineId);
          break;
        case 'Name':
          cmp = a.machineName.compareTo(b.machineName);
          break;
        default:
          cmp = 0;
      }
      return _ascending ? cmp : -cmp;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminMachineProvider);

    if (_isInitializing || _teamId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF14B8A6)),
        ),
      );
    }

    final allMachines = state.filteredMachines;
    final activeCount = _getActiveCount(allMachines);
    final inactiveCount = _getInactiveCount(allMachines);
    final suspendedCount = _getSuspendedCount(allMachines);
    final newCount = _getNewCount(allMachines);
    final filteredMachines = _getFilteredMachines(allMachines);

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
                    child: _StatCard(
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
                    child: _StatCard(
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
                    child: _StatCard(
                      title: 'Suspended Machines',
                      count: suspendedCount,
                      percentage: '-10%',
                      subtitle: 'suspended machines this month',
                      icon: Icons.settings,
                      iconColor: const Color(0xFFEF4444),
                      iconBgColor: const Color(0xFFFEE2E2),
                      isPositive: false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
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
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
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
                            // Calendar Icon
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                                color: Color(0xFF6B7280),
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
                                  setState(() => _searchQuery = value);
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        color: const Color(0xFFF9FAFB),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _applySortAndFilter(column: 'ID'),
                                child: _buildColumnHeader('ID', sortable: true),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _applySortAndFilter(column: 'Name'),
                                child: _buildColumnHeader('Name', sortable: true),
                              ),
                            ),
                            Expanded(
                              child: _buildStatusFilterHeader(),
                            ),
                            Expanded(
                              child: Center(
                                child: _buildColumnHeader('Actions', sortable: false),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Table Body
                      Expanded(
                        child: filteredMachines.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.precision_manufacturing_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No machines found',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try adjusting your search or filters',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : Scrollbar(
                                thumbVisibility: true,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  itemCount: filteredMachines.length,
                                  itemBuilder: (context, index) {
                                    final machine = filteredMachines[index];
                                    return _MachineRow(
                                      machine: machine,
                                      teamId: _teamId!,
                                      onEdit: () => _showEditDialog(machine),
                                      onView: () => _handleViewMachine(machine),
                                    );
                                  },
                                ),
                              ),
                      ),

                      // Pagination
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
                            _PaginationButton(
                              label: 'Back',
                              icon: Icons.chevron_left,
                              onPressed: () {},
                            ),
                            const SizedBox(width: 8),
                            _PaginationButton(
                              label: '1',
                              isActive: true,
                              onPressed: () {},
                            ),
                            _PaginationButton(label: '2', onPressed: () {}),
                            _PaginationButton(label: '3', onPressed: () {}),
                            _PaginationButton(label: '4', onPressed: () {}),
                            _PaginationButton(label: '5', onPressed: () {}),
                            const SizedBox(width: 8),
                            _PaginationButton(
                              label: 'Next',
                              icon: Icons.chevron_right,
                              iconRight: true,
                              onPressed: () {},
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

  Widget _buildColumnHeader(String text, {bool sortable = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
            letterSpacing: 0.5,
          ),
        ),
        if (sortable) ...[
          const SizedBox(width: 4),
          const Icon(
            Icons.unfold_more,
            size: 16,
            color: Color(0xFF9CA3AF),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusFilterHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_alt, size: 16, color: Color(0xFF6B7280)),
          onSelected: (value) {
            setState(() {
              _statusFilter = value;
            });
          },
          itemBuilder: (context) {
            return ['All', 'Active', 'Inactive', 'Suspended']
                .map((status) => PopupMenuItem(
                      value: status,
                      child: Text(status),
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
    // TODO: Implement view machine functionality
    debugPrint('View machine: ${machine.machineId}');
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final String percentage;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool isPositive;

  const _StatCard({
    required this.title,
    required this.count,
    required this.percentage,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            count.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MachineRow extends StatelessWidget {
  final MachineModel machine;
  final String teamId;
  final VoidCallback onEdit;
  final VoidCallback onView;

  const _MachineRow({
    required this.machine,
    required this.teamId,
    required this.onEdit,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final status = machine.isArchived ? 'Inactive' : 'Active';
    final statusColor = machine.isArchived
        ? const Color(0xFFFEF3C7)
        : const Color(0xFFD1FAE5);
    final statusTextColor = machine.isArchived
        ? const Color(0xFF92400E)
        : const Color(0xFF065F46);

    return InkWell(
      onTap: onView,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  machine.machineId,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  machine.machineName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: onEdit,
                      color: const Color(0xFF6B7280),
                      tooltip: 'Edit Machine',
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.open_in_new, size: 18),
                      onPressed: onView,
                      color: const Color(0xFF6B7280),
                      tooltip: 'View Machine',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool iconRight;
  final bool isActive;
  final VoidCallback onPressed;

  const _PaginationButton({
    required this.label,
    this.icon,
    this.iconRight = false,
    this.isActive = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: isActive ? const Color(0xFF10B981) : Colors.transparent,
        foregroundColor: isActive ? Colors.white : const Color(0xFF6B7280),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(40, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null && !iconRight) Icon(icon, size: 16),
          if (icon != null && !iconRight) const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          if (icon != null && iconRight) const SizedBox(width: 4),
          if (icon != null && iconRight) Icon(icon, size: 16),
        ],
      ),
    );
  }
}