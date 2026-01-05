import 'package:flutter/material.dart';
import '../../../../data/models/machine_model.dart';
import 'machine_table_header.dart';
import 'machine_table_row.dart';
import 'empty_state_widget.dart';

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

  void _handleFilterChanged(String newFilter) {
    setState(() {
      statusFilter = newFilter;
      _applySortAndFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
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
            // Table Header
            MachineTableHeader(
              sortColumn: sortColumn,
              ascending: ascending,
              statusFilter: statusFilter,
              statusOptions: statusOptions,
              onSort: (column) => _applySortAndFilter(column: column),
              onFilterChanged: _handleFilterChanged,
            ),

            // Table Rows
            Expanded(
              child: displayedMachines.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: EmptyStateWidget(),
                    )
                  : Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Column(
                          children: displayedMachines
                              .map((machine) => Column(
                                    children: [
                                      MachineTableRow(
                                        machine: machine,
                                        onActionPressed: () {
                                          widget.onMachineAction(machine.machineId);
                                        },
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
          ],
        ),
      ),
    );
  }
}