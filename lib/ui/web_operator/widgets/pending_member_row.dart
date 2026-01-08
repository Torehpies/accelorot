import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/pending_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/pending_member_action_buttons.dart';
import 'package:flutter_application_1/utils/format.dart';

class PendingMemberRow extends StatelessWidget {
  final dynamic member;
  final PendingMembersNotifier notifier;

  const PendingMemberRow({super.key, this.member, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Center(child: Text(member.firstName))),
          Expanded(flex: 2, child: Center(child: Text(member.lastName))),
          Expanded(
            flex: 3,
            child: SizedBox(
              width: 220,
              child: Center(
                child: Text(
                  member.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(child: Text(formatDateAndTime((member.requestedAt)))),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: PendingMemberActionButtons(
                notifier: notifier,
                member: member,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

DateTime _parseDate(dynamic date) {
  if (date is Timestamp) return date.toDate();
  if (date is String) return DateTime.parse(date);
  if (date is DateTime) return date;
  return DateTime.now();
}
