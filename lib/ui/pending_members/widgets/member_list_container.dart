
import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/pending_member.dart';
import 'package:flutter_application_1/ui/pending_members/widgets/member_list_tile.dart';

class MemberListContainer extends StatelessWidget {
  final List<PendingMember> members;
  final void Function(PendingMember member) onAccept;
  final void Function(PendingMember member) onDecline;

  const MemberListContainer({
    super.key,
    required this.members,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 700),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final member = members[index];
            return MemberListTile(
              member: member,
              onAccept: () => onAccept(member),
              onDecline: () => onDecline(member),
            );
          },
        ),
      ),
    );
  }
}
