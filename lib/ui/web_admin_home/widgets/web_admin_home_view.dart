// lib/ui/web_admin_home/widgets/web_admin_home_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/web_admin_home_view_model.dart';

final Color borderColor = const Color.fromARGB(255, 230, 229, 229); // #E6E6E6

class WebAdminHomeView extends ConsumerWidget {
  final VoidCallback onManageOperators;
  final VoidCallback onManageMachines;

  const WebAdminHomeView({
    super.key,
    required this.onManageOperators,
    required this.onManageMachines,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(webAdminHomeProvider);
    final webAdminNotifier = ref.read(webAdminHomeProvider.notifier);

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
            onPressed: () => webAdminNotifier.refresh(),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (stats) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stat Cards
              Row(
                children: [
                  Expanded(child: _buildInfoCard(icon: Icons.people_outline, label: 'Active Operators', count: stats.activeOperators)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoCard(icon: Icons.archive_outlined, label: 'Archived Operators', count: stats.archivedOperators)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoCard(icon: Icons.devices_other_outlined, label: 'Active Machines', count: stats.activeMachines)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInfoCard(icon: Icons.archive_rounded, label: 'Archived Machines', count: stats.archivedMachines)),
                ],
              ),
              const SizedBox(height: 30),
              // Tables
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildOperatorTable(stats.operators, onManage: onManageOperators)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildMachineTable(stats.machines, onManage: onManageMachines)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... (reuse _buildInfoCard, _buildSectionHeader, _buildIconButton from before)

  Widget _buildInfoCard({required IconData icon, required String label, required int count}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.teal),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 168, 168, 168))),
          const SizedBox(height: 4),
          Text(count.toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onManage}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal)),
        TextButton(
          onPressed: onManage,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: const Row(
            children: [
              Text('Manage', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 15)),
              Icon(Icons.arrow_forward_ios, size: 13, color: Colors.teal),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 14),
      onPressed: onPressed,
      color: color,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: BoxConstraints(),
    );
  }

  Widget _buildOperatorTable(List<Map<String, dynamic>> operators, {required VoidCallback onManage}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Operator Management', onManage: onManage),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(flex: 3, child: _headerText('Name')),
                Expanded(flex: 4, child: _headerText('Email')),
                Expanded(flex: 2, child: _headerText('Status', center: true)),
                Expanded(flex: 1, child: _headerText('Actions', center: true)),
              ],
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: operators.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final op = operators[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(op['name'], style: const TextStyle(fontWeight: FontWeight.w500))),
                      Expanded(flex: 4, child: Text(op['email'], style: const TextStyle(color: Color(0xFF494949)))),
                      Expanded(flex: 2, child: Center(child: _statusDot(op['isArchived']))),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildIconButton(Icons.edit, Colors.blue, () {}),
                            _buildIconButton(Icons.delete, Colors.red, () {}),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineTable(List<Map<String, dynamic>> machines, {required VoidCallback onManage}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Machine Management', onManage: onManage),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(flex: 4, child: _headerText('Machine')),
                Expanded(flex: 3, child: _headerText('ID')),
                Expanded(flex: 1, child: _headerText('Actions', center: true)),
              ],
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: machines.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final m = machines[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Row(
                    children: [
                      Expanded(flex: 4, child: Text(m['name'], style: const TextStyle(fontWeight: FontWeight.w500))),
                      Expanded(flex: 3, child: Text(m['machineId'], style: const TextStyle(color: Color(0xFF494949)))),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildIconButton(Icons.edit, Colors.blue, () {}),
                            _buildIconButton(Icons.delete, Colors.red, () {}),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerText(String text, {bool center = false}) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF494949)),
      textAlign: center ? TextAlign.center : TextAlign.left,
    );
  }

  Widget _statusDot(bool isArchived) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isArchived ? Colors.red : Colors.green,
      ),
    );
  }
}