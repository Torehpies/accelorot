import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../notifier/admin_dashboard_notifier.dart';
import '../widgets/swipeable_stat_cards.dart';
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
          data: (state) {
            final statCards = [
              StatCardData(
                count: state.totalOperators,
                label: 'Total Operators',
                subtitle: '+25% activated operators this month',
                icon: Icons.people,
                iconColor: Colors.teal,
                iconBackgroundColor: Colors.teal.shade50,
              ),
              StatCardData(
                count: state.totalMachines,
                label: 'Total Machines',
                subtitle: '+25% new machines this month',
                icon: Icons.precision_manufacturing,
                iconColor: Colors.blue,
                iconBackgroundColor: Colors.blue.shade50,
              ),
            ];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwipeableStatCards(cards: statCards),
                  const SizedBox(height: 20),
                  OperatorManagementSection(operators: state.operators, onManageTap: onManageOperators),
                  const SizedBox(height: 20),
                  MachineManagementSection(machines: state.machines, onManageTap: onManageMachines),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}