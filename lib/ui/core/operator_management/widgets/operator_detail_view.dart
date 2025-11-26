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
              title: const Text('Operator Details'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal,
              elevation: 0,
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
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
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.teal.shade700,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  operatorName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: vm.processing
                          ? null
                          : () async {
                              await vm.archive(operatorUid);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Archived')),
                                );
                                Navigator.pop(context, true);
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
                        vm.processing
                            ? 'Processing...'
                            : 'Archive (Temporary)',
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
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: vm.processing
                          ? null
                          : () async {
                              await vm.remove(operatorUid);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Removed from team')),
                                );
                                Navigator.pop(context, true);
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