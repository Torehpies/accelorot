import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/repositories/operator_repository.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_operator_service.dart';
import '../../operator_management/view_model/operator_management_view_model.dart';
import '../../operator_management/widgets/operator_detail_view.dart';
import '../../operator_management/widgets/add_operator_view.dart';
import '../../operator_management/widgets/accept_operator_view.dart';

class OperatorManagementView extends StatelessWidget {
  const OperatorManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OperatorManagementViewModel(
        OperatorRepositoryImpl(FirebaseOperatorService()),
      )..loadOperators(),
      child: Consumer<OperatorManagementViewModel>(
        builder: (context, vm, _) {
          final currentList = vm.showArchived
              ? vm.operators.where((o) => o.isArchived || o.hasLeft).toList()
              : vm.operators.where((o) => !o.isArchived && !o.hasLeft).toList();

          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: const Text(
                'Operator Management',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.teal,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.teal),
                  onPressed: vm.loadOperators,
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.archive,
                          label: 'Archive',
                          onPressed: () => vm.toggleShowArchived(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.person_add_alt_1,
                          label: 'Add Operator',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddOperatorView(),
                              ),
                            ).then((_) => vm.loadOperators());
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          icon: Icons.check_circle,
                          label: 'Accept Operator',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AcceptOperatorView(),
                              ),
                            ).then((_) => vm.loadOperators());
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Section Title
                  Row(
                    children: [
                      if (vm.showArchived)
                        TextButton.icon(
                          onPressed: () => vm.toggleShowArchived(),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to Active Operators'),
                          style: TextButton.styleFrom(foregroundColor: Colors.teal),
                        )
                      else
                        const Text(
                          'Lists of Operators',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Operator List
                  Expanded(
                    child: vm.loading
                        ? const Center(child: CircularProgressIndicator())
                        : vm.error != null
                            ? Center(child: Text('Error: ${vm.error}'))
                            : currentList.isEmpty
                                ? Center(
                                    child: Text(
                                      vm.showArchived
                                          ? 'No archived operators'
                                          : 'No operators available',
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    constraints: const BoxConstraints(maxWidth: 600),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: ListView.separated(
                                        padding: const EdgeInsets.all(16),
                                        itemCount: currentList.length,
                                        separatorBuilder: (context, _) =>
                                            const Divider(height: 1),
                                        itemBuilder: (context, i) {
                                          final op = currentList[i];
                                          return ListTile(
                                            title: Text(op.name),
                                            subtitle: Text(op.email),
                                            trailing: vm.showArchived
                                                ? Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      if (!op.hasLeft)
                                                        TextButton(
                                                          onPressed: () =>
                                                              vm.restoreOperator(op.uid),
                                                          child: const Text('Restore'),
                                                        ),
                                                    ],
                                                  )
                                                : TextButton(
                                                    onPressed: () =>
                                                        vm.archiveOperator(op.uid),
                                                    child: const Text('Archive'),
                                                  ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => OperatorDetailView(
                                                    operatorUid: op.uid,
                                                    operatorName: op.name,
                                                    role: op.role,
                                                    email: op.email,
                                                    dateAdded: op.addedAt?.toString() ?? '',
                                                  ),
                                                ),
                                              ).then((_) => vm.loadOperators());
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}