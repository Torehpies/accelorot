import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';
import 'package:flutter_application_1/ui/core/themes/web_text_styles.dart';
import 'package:flutter_application_1/ui/core/widgets/sticky_header.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/team_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/team_members_state.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/member_row.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/pagination_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeamMembersTab extends ConsumerStatefulWidget {
  const TeamMembersTab({super.key});

  @override
  ConsumerState<TeamMembersTab> createState() => _TeamMembersTabState();
}

class _TeamMembersTabState extends ConsumerState<TeamMembersTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(teamMembersProvider);
    final notifier = ref.read(teamMembersProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: _TableContent(state: state, notifier: notifier),
        ),
        const SizedBox(height: 12),
        _PaginationSection(
          currentPage: state.currentPage,
          hasNextPage: state.hasNextPage,
          notifier: notifier,
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _TableContent extends StatelessWidget {
  final TeamMembersState state;
  final TeamMembersNotifier notifier;

  const _TableContent({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.members.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: AppColors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            StickyHeader(
              labels: ['First Name', 'Last Name', 'Email', 'Status', 'Actions'],
              flexValues: [2, 2, 3, 1, 1],
              style: WebTextStyles.label.copyWith(color: WebColors.textLabel),
            ),
            Expanded(
              child: _MembersList(state: state, notifier: notifier),
            ),
          ],
        ),
      ),
    );
  }
}

class _MembersList extends StatelessWidget {
  final TeamMembersState state;
  final TeamMembersNotifier notifier;

  const _MembersList({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.members.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.filteredMembers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No members found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.filteredMembers.length,
      itemBuilder: (context, index) => TeamMemberRow(
        member: state.filteredMembers[index],
        notifier: notifier,
      ),
    );
  }
}

class _PaginationSection extends ConsumerWidget {
  final int currentPage;
  final bool hasNextPage;
  final TeamMembersNotifier notifier;

  const _PaginationSection({
    required this.currentPage,
    required this.hasNextPage,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaginationBar(
      currentPage: currentPage,
      canGoNext: hasNextPage,
      onBack: notifier.previousPage,
      onNext: notifier.nextPage,
      onPageSelected: notifier.goToPage,
    );
  }
}
