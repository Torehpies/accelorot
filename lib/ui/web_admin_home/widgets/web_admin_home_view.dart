// lib/ui/web_admin_home/widgets/web_admin_home_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../ui/core/ui/admin_app_bar.dart';
import '../view_model/web_admin_home_view_model.dart';
import '../../../../data/models/operator_model.dart';
import '../../../../data/models/machine_model.dart';

class WebAdminHomeView extends StatelessWidget {
  final VoidCallback onManageOperators;
  final VoidCallback onManageMachines;

  const WebAdminHomeView({
    super.key,
    required this.onManageOperators,
    required this.onManageMachines,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<WebAdminHomeViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) => viewModel.loadStats());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AdminAppBar(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: viewModel.loadStats,
          ),
        ],
      ),
      body: Consumer<WebAdminHomeViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return _WebAdminHomeContent(
            viewModel: viewModel,
            onManageOperators: onManageOperators,
            onManageMachines: onManageMachines,
          );
        },
      ),
    );
  }
}

class _WebAdminHomeContent extends StatelessWidget {
  final WebAdminHomeViewModel viewModel;
  final VoidCallback onManageOperators;
  final VoidCallback onManageMachines;
  final Color borderColor = const Color.fromARGB(255, 230, 229, 229); // #E6E6E6

  const _WebAdminHomeContent({
    required this.viewModel,
    required this.onManageOperators,
    required this.onManageMachines,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === STAT CARDS ===
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.people_outline,
                  label: 'Active Operators',
                  count: viewModel.activeOperators,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.archive_outlined,
                  label: 'Archived Operators',
                  count: viewModel.archivedOperators,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.devices_other_outlined,
                  label: 'Active Machines',
                  count: viewModel.activeMachines,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  icon: Icons.archive_rounded,
                  label: 'Archived Machines',
                  count: viewModel.archivedMachines,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // === TABLES ===
          Expanded(
            child: Row(
              children: [
                _buildOperatorTable(viewModel.recentOperators, onManageOperators, borderColor),
                const SizedBox(width: 12),
                _buildMachineTable(viewModel.recentMachines, onManageMachines, borderColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Stat card with border
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required int count,
  }) {
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
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color.fromARGB(255, 168, 168, 168),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Section header with "Manage" button
  Widget _buildSectionHeader(String title, {required VoidCallback onTapManage}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        TextButton(
          onPressed: onTapManage,
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: const Row(
            children: [
              Text(
                'Manage',
                style: TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 13,
                color: Colors.teal,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ Operator table
  Widget _buildOperatorTable(List<OperatorModel> operators, VoidCallback onManage, Color borderColor) {
    return Expanded(
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
            _buildSectionHeader('Operator Management', onTapManage: onManage),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: const [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        'Actions',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 16, color: Colors.grey),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (_, _) => const Divider(height: 16, color: Colors.grey),
                itemCount: operators.length,
                itemBuilder: (context, index) {
                  final op = operators[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            op.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            op.email,
                            style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: op.isArchived ? Colors.red : Colors.green,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 14),
                                onPressed: () {
                                  // TODO: Navigate to edit operator
                                },
                                color: Colors.blue,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 14),
                                onPressed: () {
                                  // TODO: Archive operator
                                },
                                color: Colors.red,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(),
                              ),
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
      ),
    );
  }

  // ✅ Machine table
  Widget _buildMachineTable(List<MachineModel> machines, VoidCallback onManage, Color borderColor) {
    return Expanded(
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
            _buildSectionHeader('Machine Management', onTapManage: onManage),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: const [
                  Expanded(
                    flex: 4,
                    child: Text(
                      'Machine',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'ID',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Text(
                        'Actions',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 16, color: Colors.grey),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (_, _) => const Divider(height: 16, color: Colors.grey),
                itemCount: machines.length,
                itemBuilder: (context, index) {
                  final m = machines[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            m.machineName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            m.machineId,
                            style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 73, 73, 73)),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 14),
                                onPressed: () {
                                  // TODO: Navigate to edit machine
                                },
                                color: Colors.blue,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 14),
                                onPressed: () {
                                  // TODO: Archive machine
                                },
                                color: Colors.red,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                constraints: const BoxConstraints(),
                              ),
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
      ),
    );
  }
}