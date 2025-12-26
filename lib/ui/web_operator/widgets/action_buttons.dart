import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/team_members_notifier.dart';

class ActionButtons extends StatelessWidget {
  final TeamMembersNotifier notifier;
  final dynamic member;

  const ActionButtons({
    super.key,
    required this.notifier,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit_outlined),
          onPressed: null,
          tooltip: 'Edit Member',
        ),
        IconButton(
          icon: Icon(Icons.visibility_outlined),
          onPressed: null,
          tooltip: 'View Member',
        ),
      ],
    );
  }
}
