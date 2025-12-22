import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/team_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/team_members_state.dart';
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
    final state = ref.watch(teamMembersProvider.select((s) => s));
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            _StickyHeader(),
            Expanded(
              child: _MembersList(state: state, notifier: notifier),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyHeader extends StatelessWidget {
  const _StickyHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Color(0xFFEFF7FF)),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                'First Name',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                'Last Name',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: SizedBox(
              width: 220,
              child: Center(
                child: Text(
                  'Email',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Status',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Actions',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
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
    return ListView.builder(
      itemCount: state.members.length,
      itemBuilder: (context, index) =>
          _MemberRow(member: state.members[index], notifier: notifier),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final dynamic member;
  final TeamMembersNotifier notifier;

  const _MemberRow({required this.member, required this.notifier});

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
          Expanded(flex: 1, child: Center(child: Text(member.status.value))),
          Expanded(
            flex: 1,
            child: Center(
              child: _ActionButtons(notifier: notifier, member: member),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final TeamMembersNotifier notifier;
  final dynamic member;

  const _ActionButtons({required this.notifier, required this.member});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        IconButton(icon: Icon(Icons.edit_outlined), onPressed: null),
        IconButton(icon: Icon(Icons.visibility_outlined), onPressed: null),
      ],
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
