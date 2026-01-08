import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/pending_member.dart';
import 'package:flutter_application_1/ui/core/ui/action_button.dart';
import 'package:flutter_application_1/utils/format.dart';

class MemberListTile extends StatelessWidget {
  final PendingMember member;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const MemberListTile({
    super.key,
    required this.member,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final user = member.user;
    final name = (user != null ? '${user.firstName} ${user.lastName}' : 'Unknown').trim();
    final email = user?.email ?? '-';
    final date = formatDate(member.requestedAt);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey[200]!, width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: Icon(Icons.person, color: Colors.teal.shade700, size: 20),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ActionButton.accept(onPressed: onAccept),
            const SizedBox(width: 8),
            ActionButton.decline(onPressed: onDecline),
          ],
        ),
      ),
    );
  }
}
