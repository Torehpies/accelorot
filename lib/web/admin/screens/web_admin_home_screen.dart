import 'package:flutter/material.dart';
import '../controllers/web_admin_home_controller.dart';
import '../widgets/stat_card.dart';
import '../widgets/operator_table.dart';
import '../widgets/machine_table.dart';
import '../widgets/section_header.dart';
import '../models/operator.dart';
import '../models/machine.dart';

class WebAdminHomeScreen extends StatelessWidget {
  final VoidCallback onManageOperators;
  final VoidCallback onManageMachines;

  const WebAdminHomeScreen({
    super.key,
    required this.onManageOperators,
    required this.onManageMachines,
  });

  @override
  Widget build(BuildContext context) {
    return _WebAdminHomeScreenContent(
      onManageOperators: onManageOperators,
      onManageMachines: onManageMachines,
    );
  }
}

class _WebAdminHomeScreenContent extends StatefulWidget {
  final VoidCallback onManageOperators;
  final VoidCallback onManageMachines;

  const _WebAdminHomeScreenContent({
    required this.onManageOperators,
    required this.onManageMachines,
  });

  @override
  State<_WebAdminHomeScreenContent> createState() => _WebAdminHomeScreenState();
}

class _WebAdminHomeScreenState extends State<_WebAdminHomeScreenContent> {
  final WebAdminHomeController _controller = WebAdminHomeController();
  bool _loading = true;

  int _activeOperators = 0;
  int _archivedOperators = 0;
  int _activeMachines = 0;
  int _archivedMachines = 0;

  List<Operator> _operators = [];
  List<Machine> _machines = [];

  final Color borderColor = const Color.fromARGB(255, 230, 229, 229); // #E6E6E6

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final data = await _controller.loadStats();
      if (mounted) {
        setState(() {
          _activeOperators = data['activeOperators'];
          _archivedOperators = data['archivedOperators'];
          _activeMachines = data['activeMachines'];
          _archivedMachines = data['archivedMachines'];
          _operators = List<Operator>.from(data['operators']);
          _machines = List<Machine>.from(data['machines']);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.teal.shade700,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: StatCard(icon: Icons.people_outline, label: 'Active Operators', count: _activeOperators, borderColor: borderColor)),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(icon: Icons.archive_outlined, label: 'Archived Operators', count: _archivedOperators, borderColor: borderColor)),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(icon: Icons.devices_other_outlined, label: 'Active Machines', count: _activeMachines, borderColor: borderColor)),
                      const SizedBox(width: 12),
                      Expanded(child: StatCard(icon: Icons.archive_rounded, label: 'Archived Machines', count: _archivedMachines, borderColor: borderColor)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderColor, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionHeader(title: 'Operator Management', onTapManage: widget.onManageOperators),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: const [
                                      Expanded(flex: 3, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)))),
                                      Expanded(flex: 4, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)))),
                                      Expanded(flex: 2, child: Text('Status', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)))),
                                      Expanded(flex: 1, child: Text('Actions', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)))),
                                    ],
                                  ),
                                ),
                                const Divider(height: 16, color: Colors.grey),
                                OperatorTable(
                                  operators: _operators,
                                  onEdit: () {},
                                  onDelete: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderColor, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionHeader(title: 'Machine Management', onTapManage: widget.onManageMachines),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: const [
                                      Expanded(flex: 4, child: Text('Machine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)))),
                                      Expanded(flex: 3, child: Text('ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)))),
                                      Expanded(flex: 1, child: Text('Actions', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)))),
                                    ],
                                  ),
                                ),
                                const Divider(height: 16, color: Colors.grey),
                                MachineTable(
                                  machines: _machines,
                                  onEdit: () {},
                                  onDelete: () {},
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}