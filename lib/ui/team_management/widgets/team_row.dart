import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/ui/core/constants/spacing.dart';
import 'package:flutter_application_1/ui/core/themes/web_text_styles.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_action_buttons.dart';
import 'package:flutter_application_1/ui/core/widgets/table/table_row.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_management_notifier.dart';
import 'package:flutter_application_1/ui/team_management/widgets/view_team_dialog.dart';
import 'package:go_router/go_router.dart';

class TeamRow extends StatelessWidget {
  final Team team;
  final TeamManagementNotifier notifier;

  const TeamRow({super.key, required this.team, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return GenericTableRow(
      hoverColor: const Color(0xFFF9FAFB),
      cellSpacing: AppSpacing.md,
      cells: [
        TableCellWidget(
          flex: 2,
          child: Text(
            team.teamName,
            style: WebTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        TableCellWidget(
          flex: 2,
          child: Text(
            team.address,
            style: WebTextStyles.body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        TableCellWidget(
          flex: 1,
          child: Center(
            child: TableActionButtons(
              actions: [
                TableActionButton(
                  icon: Icons.info,
                  tooltip: 'Quick View',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ViewTeamDialog(team: team),
                    );
                  },
                ),
                TableActionButton(
                  icon: Icons.arrow_right,
                  tooltip: 'View Team',
                  onPressed: () {
                    context.pushNamed(
                      'teamDetails',
                      pathParameters: {'teamId': team.teamId.toString()},
                      extra: team,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
