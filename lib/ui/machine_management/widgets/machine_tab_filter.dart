import 'package:flutter/material.dart';
import '../view_model/admin_machine_notifier.dart';

class MachineTabFilter extends StatelessWidget {
  final MachineFilterTab selectedTab;
  final Function(MachineFilterTab) onTabSelected;

  const MachineTabFilter({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTab('All', MachineFilterTab.all),
          const SizedBox(width: 8),
          _buildTab('Active', MachineFilterTab.active),
          const SizedBox(width: 8),
          _buildTab('Inactive', MachineFilterTab.suspended),
          const SizedBox(width: 8),
          _buildTab('Archived', MachineFilterTab.archived),
        ],
      ),
    );
  }

  Widget _buildTab(String label, MachineFilterTab tab) {
    final isSelected = selectedTab == tab;

    Color backgroundColor;
    Color textColor;

    if (isSelected) {
      switch (tab) {
        case MachineFilterTab.all:
          backgroundColor = const Color(0xFF6B7280);
          textColor = Colors.white;
          break;
        case MachineFilterTab.active:
          backgroundColor = const Color(0xFF4CAF50);
          textColor = Colors.white;
          break;
        case MachineFilterTab.archived:
          backgroundColor = const Color(0xFFFFA726);
          textColor = Colors.white;
          break;
        case MachineFilterTab.suspended:
          backgroundColor = const Color(0xFFEF5350);
          textColor = Colors.white;
          break;
      }
    } else {
      backgroundColor = Colors.white;
      textColor = const Color(0xFF6B7280);
    }

    return GestureDetector(
      onTap: () => onTabSelected(tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: tab == MachineFilterTab.all
                        ? const Color(0x4D6B7280)
                        : tab == MachineFilterTab.active
                        ? const Color(0x4D4CAF50)
                        : tab == MachineFilterTab.archived
                        ? const Color(0x4DFFA726)
                        : const Color(0x4DEF5350),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
