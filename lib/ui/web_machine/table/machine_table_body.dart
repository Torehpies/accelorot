// lib/ui/machine_management/widgets/admin/table/machine_table_body.dart

import 'package:flutter/material.dart';
import '../../../../data/models/machine_model.dart';
import '../../../../ui/web_machine/shared/web_machine_empty_state.dart';
import '../../../../ui/web_machine/shared/web_no_team_state.dart';
import '../../core/themes/web_colors.dart';
import 'machine_table_row.dart';

class MachineTableBody extends StatelessWidget {
  final List<MachineModel> items;
  final ValueChanged<MachineModel> onViewDetails;
  final ValueChanged<MachineModel> onEdit;
  final bool isLoading;
  final bool isEmpty;
  final bool hasNoTeam;

  const MachineTableBody({
    super.key,
    required this.items,
    required this.onViewDetails,
    required this.onEdit,
    this.isLoading = false,
    this.isEmpty = false,
    this.hasNoTeam = false,
  });

  @override
  Widget build(BuildContext context) {
    if (hasNoTeam) {
      return const Padding(padding: EdgeInsets.all(16.0), child: NoTeamState());
    }

    if (isEmpty || items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: MachineEmptyState(),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, thickness: 1, color: WebColors.tableBorder),
      itemBuilder: (context, index) {
        return MachineTableRow(
          machine: items[index],
          onViewDetails: onViewDetails,
          onEdit: onEdit,
        );
      },
    );
  }
}
