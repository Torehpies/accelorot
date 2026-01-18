import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/data_bottom_sheet.dart';
import 'package:flutter_application_1/ui/core/widgets/data_card.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/team_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/team_members_state.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/edit_operator_dialog.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/status_badge.dart';
import 'package:flutter_application_1/utils/format.dart';
import 'package:flutter_application_1/utils/getOperatorStatusStyle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileTeamMembersTab extends ConsumerStatefulWidget {
  const MobileTeamMembersTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MobileTeamMembersState();
}

class _MobileTeamMembersState extends ConsumerState<MobileTeamMembersTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(teamMembersProvider);
    final notifier = ref.read(teamMembersProvider.notifier);
    return _MembersList(state: state, notifier: notifier);
  }
}

class _MembersList extends StatelessWidget {
  final TeamMembersState state;
  final TeamMembersNotifier notifier;

  const _MembersList({required this.state, required this.notifier});

  void _showEditDialog(
    BuildContext context,
    TeamMembersNotifier notifier,
    TeamMember member,
  ) {
    showDialog(
      context: context,
      builder: (context) => EditOperatorDialog(
        operator: member,
        onSave: (updatedOperator) => notifier.updateOperator(updatedOperator),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.members.length,
      itemBuilder: (context, index) {
        TeamMember member = state.members[index];
        StatusStyle statusStyle = getStatusStyle(member.status.value);
        return DataCard<TeamMember>(
          data: member,
          icon: Icons.person,
          iconBgColor: AppColors.green100,
          title: "${member.lastName} ${member.firstName}",
          category: toTitleCase(member.status.value),
          categoryTitle: "Status",
          status: member.email,
          categoryColor: statusStyle.color,
          categoryTextColor: statusStyle.textColor,
          onAction: (action, member) {
            switch (action) {
              case 'view':
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) => DataBottomSheet<TeamMember>(
                    data: member,
                    title: '${member.lastName}, ${member.firstName}',
                    avatarIcon: Icons.person,
                    avatarColor: AppColors.green100,
                    details: [
                      MapEntry('Email', member.email),
                      MapEntry('Status', toTitleCase(member.status.value)),
                      MapEntry('Created', formatDateAndTime(member.addedAt)),
                    ],
                    primaryActionLabel: 'Edit',
                    onPrimaryAction: (member) =>
                        _showEditDialog(context, notifier, member),
                  ),
                );
                break;
            }
          },
        );
      },
    );
  }
}
