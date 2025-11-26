import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/data/repositories/operator_repository.dart';
import 'package:flutter_application_1/data/services/firebase/firebase_operator_service.dart';
import '../../operator_management/view_model/accept_operator_view_model.dart';

class AcceptOperatorView extends StatelessWidget {
  const AcceptOperatorView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AcceptOperatorViewModel(
        OperatorRepositoryImpl(FirebaseOperatorService()),
      )..loadPending(),
      child: Consumer<AcceptOperatorViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: const Text(
                'Accept Operator Invitations',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.teal),
                  onPressed: vm.loadPending,
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pending Invitations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: vm.loading
                        ? const Center(child: CircularProgressIndicator())
                        : vm.error != null
                            ? Center(child: Text('Error: ${vm.error}'))
                            : vm.pendingMembers.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No pending invitations',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: vm.pendingMembers.length,
                                    separatorBuilder: (context, _) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, i) {
                                      final m = vm.pendingMembers[i];
                                      return Card(
                                        child: ListTile(
                                          title: Text(m['name'] ?? 'Unknown'),
                                          subtitle: Text(m['email'] ?? ''),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () => vm.accept(i),
                                                child: const Text('Accept'),
                                              ),
                                              const SizedBox(width: 8),
                                              OutlinedButton(
                                                onPressed: () => vm.decline(i),
                                                child: const Text('Decline'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
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
}