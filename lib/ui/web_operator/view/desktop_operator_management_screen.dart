import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/pending_members_tab.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/summary_header.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/team_header_with_tabs.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/team_members_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopOperatorManagementScreen extends ConsumerWidget {
  const DesktopOperatorManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: Column(
          children: [
            const SummaryHeader(),
            SizedBox(height: 10),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.background2,
                ),
                child: Column(
                  children: [
                    // header row with tabs + search/buttons
                    const TeamHeaderWithTabs(),

                    const SizedBox(height: 8),

                    // Tab contents fill the rest
                    const Expanded(
                      child: TabBarView(
                        children: [TeamMembersTab(), PendingMembersTab()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
