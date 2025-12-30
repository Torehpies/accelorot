// lib/ui/mobile_admin_home/view/mobile_admin_home_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifier/admin_dashboard_notifier.dart';
import '../widgets/stat_card.dart';
import '../widgets/operator_management_section.dart';
import '../widgets/machine_management_section.dart';

class MobileAdminHomeView extends ConsumerWidget {
  final VoidCallback onManageOperators;
  final VoidCallback onManageMachines;

  const MobileAdminHomeView({
    super.key,
    required this.onManageOperators,
    required this.onManageMachines,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(adminDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade600,
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No new notifications')),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(adminDashboardProvider.notifier).loadData();
        },
        child: asyncState.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (state) => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: StatCard(count: state.totalOperators, label: 'Operators')),
                    const SizedBox(width: 16),
                    Expanded(child: StatCard(count: state.totalMachines, label: 'Machines')),
                  ],
                ),
                const SizedBox(height: 20),
                OperatorManagementSection(operators: state.operators, onManageTap: onManageOperators),
                const SizedBox(height: 20),
                MachineManagementSection(machines: state.machines, onManageTap: onManageMachines),
              ],
            ),
          ),
        ),
      ),
    );
  }
}