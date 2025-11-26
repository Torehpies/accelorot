import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/repositories/operator_repository.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_operator_service.dart';
import '../../operator_management/view_model/operator_detail_view_model.dart';

class OperatorDetailView extends StatelessWidget {
  final String operatorUid;
  final String operatorName;
  final String role;
  final String email;
  final String dateAdded;

  const OperatorDetailView({
    super.key,
    required this.operatorUid,
    required this.operatorName,
    this.role = 'Operator',
    this.email = '',
    this.dateAdded = '',
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OperatorDetailViewModel(
        OperatorRepositoryImpl(FirebaseOperatorService()),
      ),
      child: Consumer<OperatorDetailViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.teal),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Operator Details',
                style: TextStyle(color: Colors.teal),
              ),
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal,
              elevation: 0,
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Operator Info Card
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.teal.shade700,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  operatorName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildDetailRow('Role:', role),
                          const SizedBox(height: 12),
                          _buildDetailRow('Email:', email),
                          const SizedBox(height: 12),
                          _buildDetailRow('Date Added:', dateAdded),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Archive button (temporary restriction)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: vm.processing
                          ? null
                          : () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Archive Operator'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Archive $operatorName?'),
                                      const SizedBox(height: 12),
                                      const Text(
                                        '• Operator will be temporarily restricted',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      const Text(
                                        '• Can be restored later',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      const Text(
                                        '• Operator cannot login while archived',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Archive'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && context.mounted) {
                                await vm.archive(operatorUid);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('$operatorName has been archived'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  Navigator.pop(context, true);
                                }
                              }
                            },
                      icon: vm.processing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.archive),
                      label: Text(
                        vm.processing ? 'Processing...' : 'Archive (Temporary)',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Remove button (permanent)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: vm.processing
                          ? null
                          : () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Remove from Team'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Remove $operatorName from this team?'),
                                      const SizedBox(height: 12),
                                      const Text(
                                        '⚠️ This action is permanent:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        '• Operator will be marked as "Left Team"',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      const Text(
                                        '• Cannot be restored (must rejoin via invite)',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      const Text(
                                        '• Operator can join other teams',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      const Text(
                                        '• Data retained in archive for records',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && context.mounted) {
                                await vm.remove(operatorUid);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '$operatorName has been removed from the team',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  Navigator.pop(context, true);
                                }
                              }
                            },
                      icon: vm.processing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.exit_to_app),
                      label: Text(
                        vm.processing
                            ? 'Processing...'
                            : 'Remove from Team (Permanent)',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Archive: Temporary restriction, can be restored.\nRemove: Permanent, operator must rejoin via invite.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade900,
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
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.teal,
            ),
          ),
        ),
      ],
    );
  }
}