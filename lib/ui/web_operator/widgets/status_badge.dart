import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/format.dart';
import 'package:flutter_application_1/utils/get_operator_status_style.dart';

typedef StatusStyle = ({Color color, Color textColor});

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final titleCaseStatus = toTitleCase(status);
    final statusStyle = getStatusStyle(titleCaseStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusStyle.color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        titleCaseStatus,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: statusStyle.textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
