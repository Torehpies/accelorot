import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view_model/web_admin_home_provider.dart';
import '../../../../ui/core/ui/admin_app_bar.dart';
import '../../../../data/models/operator_model.dart';
import '../../../../data/models/machine_model.dart';

// TODO - Issue with callbacks, no need for callbacks and parameters for the screen
// Handle the logic internally or in the notifier/view model
class WebAdminHomeView extends ConsumerStatefulWidget {
  final VoidCallback onManageOperators;
  final VoidCallback onManageMachines;

  const WebAdminHomeView({
    super.key,
    required this.onManageOperators,
    required this.onManageMachines,
  });

  @override
  ConsumerState<WebAdminHomeView> createState() =>
      _WebAdminHomeViewState();
}

class _WebAdminHomeViewState extends ConsumerState<WebAdminHomeView> {
  @override
  void initState() {
    super.initState();

    /// ✅ Call Notifier (Riverpod 3)
    Future.microtask(() {
      ref.read(webAdminHomeProvider.notifier).loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    /// ✅ Watch STATE (not ViewModel)
    final state = ref.watch(webAdminHomeProvider);
    final notifier = ref.read(webAdminHomeProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AdminAppBar(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: notifier.loadStats,
          ),
        ],
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : _WebAdminHomeContent(
              state: state,
              onManageOperators: widget.onManageOperators,
              onManageMachines: widget.onManageMachines,
            ),
    );
  }
}

class _WebAdminHomeContent extends StatelessWidget {
  final WebAdminHomeState state;
  final VoidCallback onManageOperators;
  final VoidCallback onManageMachines;

  const _WebAdminHomeContent({
    required this.state,
    required this.onManageOperators,
    required this.onManageMachines,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              _statCard('Active Operators', state.activeOperators),
              _statCard('Archived Operators', state.archivedOperators),
              _statCard('Active Machines', state.activeMachines),
              _statCard('Archived Machines', state.archivedMachines),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: Row(
              children: [
                _operatorTable(
                  state.recentOperators,
                  onManageOperators,
                ),
                const SizedBox(width: 12),
                _machineTable(
                  state.recentMachines,
                  onManageMachines,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, int count) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _operatorTable(
    List<OperatorModel> operators,
    VoidCallback onManage,
  ) {
    return Expanded(
      child: Card(
        child: Column(
          children: [
            _sectionHeader('Operator Management', onManage),
            Expanded(
              child: ListView.builder(
                itemCount: operators.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(operators[i].name),
                  subtitle: Text(operators[i].email),
                  trailing: Icon(
                    Icons.circle,
                    size: 10,
                    color:
                        operators[i].isArchived ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _machineTable(
    List<MachineModel> machines,
    VoidCallback onManage,
  ) {
    return Expanded(
      child: Card(
        child: Column(
          children: [
            _sectionHeader('Machine Management', onManage),
            Expanded(
              child: ListView.builder(
                itemCount: machines.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(machines[i].machineName),
                  subtitle: Text(machines[i].machineId),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: onTap,
            child: const Text('Manage'),
          ),
        ],
      ),
    );
  }
}

