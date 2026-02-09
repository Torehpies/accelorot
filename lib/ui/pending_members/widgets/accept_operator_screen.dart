import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/ui/status_message.dart';
import 'package:flutter_application_1/ui/pending_members/view_model/pending_members_notifier.dart';
import 'package:flutter_application_1/ui/pending_members/widgets/member_list_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AcceptOperatorScreen extends ConsumerWidget {
  const AcceptOperatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      pendingMembersProvider.select((s) => s.isLoadingMembers),
    );
    final isSaving = ref.watch(
      pendingMembersProvider.select((s) => s.isSavingMembers),
    );
    final members = ref.watch(pendingMembersProvider.select((s) => s.members));

    final notifier = ref.read(pendingMembersProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Accept Operator Invitations',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: (isLoading || isSaving)
                ? null
                : () {
                    ref
                        .read(pendingMembersProvider.notifier)
                        .fetchMembers(forceRefresh: true);
                  },
            icon: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Icon(Icons.refresh, color: Colors.teal),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
              child: members.isEmpty && !isLoading
                  ? StatusMessage.empty(title: "No pending requests")
                  : Builder(
                      builder: (_) {
                        if (isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return MemberListContainer(
                          members: members,
                          onAccept: notifier.acceptInvitation,
                          onDecline: notifier.declineInvitation,
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
