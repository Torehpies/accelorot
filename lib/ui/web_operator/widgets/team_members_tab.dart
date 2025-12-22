import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/team_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/pagination_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamMembersTab extends ConsumerWidget {
  const TeamMembersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamMembersProvider);
    final notifier = ref.read(teamMembersProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: state.isLoading && state.members.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LayoutBuilder(
                      builder:
                          (
                            BuildContext context,
                            BoxConstraints constraints,
                          ) => SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                                maxWidth: constraints.maxWidth,
                              ),
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  const Color(0xFFEFF7FF),
                                ),
                                columns: const [
                                  DataColumn(label: Text('First Name')),
                                  DataColumn(label: Text('Last Name')),
                                  DataColumn(label: Text('Email')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Date Added')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: state.members.map((m) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(m.firstName)),
                                      DataCell(Text(m.lastName)),
                                      DataCell(Text(m.email)),
                                      DataCell(Text(m.status.value)),
                                      DataCell(Text(_formatDate(m.addedAt))),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.visibility_outlined,
                                              ),
                                              onPressed: () {
                                                // TODO: view dialog / route
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                              ),
                                              onPressed: () {
                                                // TODO: edit form
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.archive_outlined,
                                              ),
                                              onPressed: () {
                                                // notifier.archiveTeamMemberForRow(m);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 12),
        PaginationBar(
          currentPage: state.currentPage,
          canGoNext: state.hasNextPage,
          onBack: notifier.previousPage,
          onNext: notifier.nextPage,
          onPageSelected: notifier.goToPage,
        ),
      ],
    );
  }

  String _formatDate(DateTime value) {
    // Replace with intl if you like
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  }
}
