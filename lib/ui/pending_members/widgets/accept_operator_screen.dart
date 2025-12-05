import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/pending_member.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/providers/pending_member_providers.dart';
import 'package:flutter_application_1/ui/pending_members/view_model/pending_members_notifier.dart';
import 'package:flutter_application_1/utils/format.dart' show formatDate;
import 'package:flutter_application_1/utils/snackbar_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AcceptOperatorScreen extends ConsumerWidget {
  const AcceptOperatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(pendingMembersProvider.select((s) => s.members));
    final pendingMembersNotifier = ref.read(pendingMembersProvider.notifier);
    final pendingMemberRepository = ref.read(pendingMemberRepositoryProvider);
    final currentUser = ref.watch(appUserProvider);

    //TODO use when() on checking of the result
    Future<void> acceptInvitation(PendingMember member) async {
      try {
        await pendingMemberRepository.acceptInvitation(
          teamId: currentUser.value!.teamId,
          member: member,
        );
        showSnackbar(context, 'Accepted $member.user.firstName to the team');
      } catch (e) {
        showSnackbar(context, 'Error accepting member $e', isError: true);
      }
    }

    Future<void> declineInvitation(PendingMember member) async {
      try {
        await pendingMemberRepository.declineInvitation(
          teamId: currentUser.value!.teamId,
          member: member,
        );
        showSnackbar(context, "Declined $member.user.firstName's request");
      } catch (e) {
        showSnackbar(
          context,
          "Error declining member's request $e",
          isError: true,
        );
      }
    }

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
            icon: const Icon(Icons.refresh, color: Colors.teal),
            onPressed: () => pendingMembersNotifier.fetchPage(),
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

            // List of pending members
            Expanded(
              child: members.isEmpty
                  ? const Center(
                      child: Text(
                        'No pending invitations',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Container(
                      constraints: const BoxConstraints(maxWidth: 700),
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
                          itemCount: members.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final member = members[index];
                            final name =
                                '${member.user?.firstName ?? ''} ${member.user?.lastName ?? ''}'
                                    .trim();
                            final email = member.user?.email ?? '';
                            final date = formatDate(member.requestedAt);
                            return Card(
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusDirectional.circular(
                                  14,
                                ),
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
                                    color: Colors.teal.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.teal.shade700,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  name.isNotEmpty ? name : 'Unknown',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      email,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      date,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal.shade600,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () => acceptInvitation(member),
                                      child: const Text(
                                        'Accept',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red.shade700,
                                        side: BorderSide(
                                          color: Colors.red.shade100,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () =>
                                          declineInvitation(member),
                                      child: const Text(
                                        'decline',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
              // error: (error, stack) => Center(
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       const Text(
              //         'Error loading pending members',
              //         style: TextStyle(color: Colors.red),
              //       ),
              //       const SizedBox(height: 8),
              //       Text(
              //         error.toString(),
              //         textAlign: TextAlign.center,
              //         style: const TextStyle(color: Colors.red, fontSize: 12),
              //       ),
              //       const SizedBox(height: 16),
              //       ElevatedButton(
              //         onPressed: () => pendingMembersNotifier.fetchPage(
              //           teamId: "Qr3OXuxz9huXaG0vqNkT",
              //         ),
              //         child: const Text('Retry'),
              //       ),
              //     ],
              //   ),
              // ),
              // loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
