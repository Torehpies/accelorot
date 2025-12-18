import 'package:flutter/material.dart';
import '../models/machines_view_model.dart';

class MachineTableWidget extends StatefulWidget {
  final List<Machine> machines;
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
  late List<Machine> displayedMachines;
  String sortColumn = 'ID';
  bool ascending = true;
  String statusFilter = 'All';

  final List<String> statusOptions = ['All', 'Active', 'Inactive', 'Suspended'];

  @override
  void initState() {
    super.initState();
    displayedMachines = List.from(widget.machines);
    _applySortAndFilter();
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
      return machine.status.toLowerCase() == statusFilter.toLowerCase();
    }).toList();

    displayedMachines.sort((a, b) {
      int cmp;
      switch (sortColumn) {
        case 'ID':
          cmp = a.id.compareTo(b.id);
          break;
        case 'Name':
          cmp = ('${a.firstName} ${a.lastName}')
              .compareTo('${b.firstName} ${b.lastName}');
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
    const headerStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF6B7280),
      letterSpacing: 0.5,
    );

    const rowStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFF111827),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8), // slightly smaller radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03), // lighter shadow
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // reduced padding
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
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
                                      _buildTableRow(machine, rowStyle),
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
          ),
        ),
        const SizedBox(width: 4),
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_alt, size: 16, color: Color(0xFF6B7280)),
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
                      child: Text(status),
                    ))
                .toList();
          },
        ),
      ],
    );
  }

  Widget _buildTableRow(Machine machine, TextStyle rowStyle) {
    return InkWell(
      onTap: () => widget.onMachineAction(machine.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // reduced vertical padding
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  machine.id,
                  style: rowStyle.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '${machine.firstName} ${machine.lastName}',
                  style: rowStyle,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: Center(child: _buildStatusBadge(machine.status)),
            ),
            Expanded(
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  color: const Color(0xFF6B7280),
                  onPressed: () => widget.onMachineAction(machine.id),
                  tooltip: 'View Machine',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'active':
        bgColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF065F46);
        break;
      case 'inactive':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        break;
      case 'suspended':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF4B5563);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), // smaller badge
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

  static Widget _buildEmptyState() {
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
