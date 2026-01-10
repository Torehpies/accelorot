import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/team_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/status_badge.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/team_member_action_buttons.dart';

class TeamMemberRow extends StatelessWidget {
  final dynamic member;
  final TeamMembersNotifier notifier;

  const TeamMemberRow({super.key, this.member, required this.notifier});

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
            flex: 1,
            child: Center(child: StatusBadge(status: member.status.value)),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: TeamMemberActionButtons(notifier: notifier, member: member),
            ),
          ),
        ],
      ),
    );
  }
}
