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
              centerTitle: false,
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

                  // Section Title or Back Button
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
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Error loading operators:',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      vm.error ?? '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: vm.loadOperators,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
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
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          final op = currentList[index];
                                          final hasLeft = op.hasLeft;
                                          final isArchived = op.isArchived;

                                          return Card(
                                            elevation: 0,
                                            margin: EdgeInsets.zero,
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                              side: BorderSide(
                                                color: Colors.grey[200]!,
                                                width: 0.5,
                                              ),
                                            ),
                                            child: ListTile(
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                              leading: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: hasLeft
                                                      ? Colors.red.shade100
                                                      : isArchived
                                                          ? Colors.orange.shade100
                                                          : Colors.teal.shade100,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.person,
                                                  color: hasLeft
                                                      ? Colors.red.shade700
                                                      : isArchived
                                                          ? Colors.orange.shade700
                                                          : Colors.teal.shade700,
                                                  size: 20,
                                                ),
                                              ),
                                              title: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      op.name,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  if (hasLeft)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red.shade50,
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(
                                                          color: Colors.red.shade200,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Left Team',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.red.shade700,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    op.email,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  if (vm.showArchived) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      hasLeft
                                                          ? 'Left: ${_formatDateTime(op.leftAt)}'
                                                          : 'Archived: ${_formatDateTime(op.archivedAt)}',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              trailing: vm.showArchived
                                                  ? (hasLeft
                                                      ? null
                                                      : ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.teal.shade100,
                                                            foregroundColor: Colors.teal.shade800,
                                                            padding: const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 4,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            await vm.restoreOperator(op.uid);
                                                            if (context.mounted) {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    '${op.name} restored successfully',
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: const Text(
                                                            'Restore',
                                                            style: TextStyle(fontSize: 12),
                                                          ),
                                                        ))
                                                  : const Icon(
                                                      Icons.chevron_right,
                                                      color: Colors.teal,
                                                    ),
                                              onTap: (vm.showArchived && hasLeft)
                                                  ? null
                                                  : vm.showArchived
                                                      ? null
                                                      : () async {
                                                          final shouldRefresh = await Navigator.push<bool>(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) => OperatorDetailView(
                                                                operatorUid: op.uid,
                                                                operatorName: op.name,
                                                                role: op.role,
                                                                email: op.email,
                                                                dateAdded: _formatDateTime(op.addedAt),
                                                              ),
                                                            ),
                                                          );

                                                          if (shouldRefresh == true) {
                                                            vm.loadOperators();
                                                          }
                                                        },
                                            ),
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

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    return '${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}-${dateTime.year}';
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
                      blurRadius: 10,
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