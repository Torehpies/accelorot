import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';
import 'package:flutter_application_1/ui/core/themes/web_text_styles.dart';
import 'package:flutter_application_1/ui/core/widgets/sticky_header.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/pending_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/pending_members_state.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/pagination_bar.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/pending_member_row.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingMembersTab extends ConsumerStatefulWidget {
  const PendingMembersTab({super.key});

  @override
  ConsumerState<PendingMembersTab> createState() => _PendingMembersTabState();
}

class _PendingMembersTabState extends ConsumerState<PendingMembersTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(pendingMembersProvider);
    final notifier = ref.read(pendingMembersProvider.notifier);

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
  final PendingMembersState state;
  final PendingMembersNotifier notifier;

  const _TableContent({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final isTablet =
        MediaQuery.of(context).size.width >= kTabletBreakpoint &&
        MediaQuery.of(context).size.width < kDesktopBreakpoint;

    if (state.isLoading && state.filteredMembers.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.filteredMembers.isEmpty && !state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No pending members found'),
          ],
        ),
      );
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
            // _StickyHeader(),
            StickyHeader(
              labels: [
                'First Name',
                'Last Name',
                'Email',
                'Requested At',
                'Actions',
              ],
              flexValues: [isTablet ? 1 : 2, isTablet ? 1 : 2, 3, 2, 1],
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
  final PendingMembersState state;
  final PendingMembersNotifier notifier;

  const _MembersList({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.filteredMembers.length,
      itemBuilder: (context, index) => PendingMemberRow(
        member: state.filteredMembers[index],
        notifier: notifier,
      ),
    );
  }
}

class _PaginationSection extends ConsumerWidget {
  final int currentPage;
  final bool hasNextPage;
  final PendingMembersNotifier notifier;

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
