import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/machine_model.dart';

class MachineTableWidget extends StatefulWidget {
  final List<MachineModel> machines;
  final Function(String) onMachineAction;

  const MachineTableWidget({
    super.key,
    required this.machines,
    required this.onMachineAction,
  });

  @override
  State<MachineTableWidget> createState() => _MachineTableWidgetState();
}

class _MachineTableWidgetState extends State<MachineTableWidget> {
  late List<MachineModel> displayedMachines;
  String sortColumn = 'ID';
  bool ascending = true;
  String statusFilter = 'All';

  final List<String> statusOptions = ['All', 'Active', 'Archived'];

  @override
  void initState() {
    super.initState();
    displayedMachines = List.from(widget.machines);
    _applySortAndFilter();
  }

  @override
  void didUpdateWidget(MachineTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.machines != oldWidget.machines) {
      displayedMachines = List.from(widget.machines);
      _applySortAndFilter();
    }
  }

  void _applySortAndFilter({String? column}) {
    if (column != null) {
      if (sortColumn == column) {
        ascending = !ascending;
      } else {
        sortColumn = column;
        ascending = true;
      }
    }

    displayedMachines = widget.machines.where((machine) {
      if (statusFilter == 'All') return true;
      if (statusFilter == 'Active') return !machine.isArchived;
      if (statusFilter == 'Archived') return machine.isArchived;
      return true;
    }).toList();

    displayedMachines.sort((a, b) {
      int cmp;
      switch (sortColumn) {
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
      return ascending ? cmp : -cmp;
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
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
                    flex: 1,
                    child: Center(
                      child: _buildColumnHeader('Actions', sortable: false),
                    ),
                  ),
                ],
              ),
            ),

            // Table Rows
            Expanded(
              child: displayedMachines.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildEmptyState(),
                    )
                  : Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Column(
                          children: displayedMachines
                              .map((machine) => Column(
                                    children: [
                                      _buildTableRow(machine),
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
          ],
        ),
      ),
    );
  }

  Widget _buildColumnHeader(String text, {bool sortable = false}) {
    final isCurrentSort = sortColumn == text || 
                          (sortColumn == 'ID' && text == 'Machine ID') ||
                          (sortColumn == 'Created' && text == 'Created');
    
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
                ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
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
            color: statusFilter != 'All' 
                ? const Color(0xFF3B82F6) 
                : const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.filter_alt,
            size: 16,
            color: statusFilter != 'All' 
                ? const Color(0xFF3B82F6) 
                : const Color(0xFF6B7280),
          ),
          onSelected: (value) {
            setState(() {
              statusFilter = value;
              _applySortAndFilter();
            });
          },
          itemBuilder: (context) {
            return statusOptions
                .map((status) => PopupMenuItem(
                      value: status,
                      child: Row(
                        children: [
                          if (statusFilter == status)
                            const Icon(
                              Icons.check,
                              size: 16,
                              color: Color(0xFF3B82F6),
                            ),
                          if (statusFilter == status) const SizedBox(width: 8),
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

  Widget _buildTableRow(MachineModel machine) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // Machine ID
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                machine.machineId,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),

          // Name
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                machine.machineName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Date Created
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                dateFormat.format(machine.dateCreated),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),

          // Status
          Expanded(
            flex: 2,
            child: Center(
              child: _buildStatusBadge(machine.isArchived),
            ),
          ),

          // ✅ Actions (ONLY clickable part)
          Expanded(
            flex: 1,
            child: Center(
              child: IconButton(
                icon: const Icon(Icons.open_in_new, size: 18),
                color: const Color(0xFF6B7280),
                tooltip: 'View Machine',
                onPressed: () {
                  widget.onMachineAction(machine.machineId);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isArchived) {
    final status = isArchived ? 'Archived' : 'Active';
    final bgColor = isArchived 
        ? const Color(0xFFFEF3C7) 
        : const Color(0xFFD1FAE5);
    final textColor = isArchived 
        ? const Color(0xFF92400E) 
        : const Color(0xFF065F46);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.precision_manufacturing_outlined,
            size: 64,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 16),
          Text(
            'No machines found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}