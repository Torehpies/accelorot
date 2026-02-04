import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/pending_member/pending_member.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/core/ui/confirm_dialog.dart';
import 'package:flutter_application_1/ui/core/widgets/data_card.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/pending_members_state.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/pending_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/bottom_sheets/pending_member_view_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobilePendingMembersTab extends ConsumerStatefulWidget {
  const MobilePendingMembersTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MobileTeamMembersState();
}

class _MobileTeamMembersState extends ConsumerState<MobilePendingMembersTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(pendingMembersProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(pendingMembersProvider);
    final notifier = ref.read(pendingMembersProvider.notifier);
    return _MembersList(
      state: state,
      notifier: notifier,
      scrollController: _scrollController,
    );
  }
}

class _MembersList extends StatelessWidget {
  final PendingMembersState state;
  final PendingMembersNotifier notifier;
  final ScrollController scrollController;

  const _MembersList({
    required this.state,
    required this.notifier,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.items.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    if (state.items.isEmpty && !state.isLoading) {
      return Center(
        child: Text(
          'No pending requests found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }
    return ListView.separated(
      controller: scrollController,
      padding: EdgeInsets.all(16),
      separatorBuilder: (_, _) => SizedBox(height: 2),
      itemCount: state.items.length + (state.hasNextPage ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return _buildLoadingItem();
        }
        PendingMember member = state.items[index];
        return DataCard<PendingMember>(
          data: member,
          icon: Icons.person,
          iconBgColor: AppColors.green100,
          title: "${member.lastName}, ${member.firstName}",
          status: member.email,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => PendingMemberViewSheet(
                member: member,
                onAccept: () => _showAcceptDialog(context, member),
                onDecline: () => _showDeclineDialog(context, member),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showAcceptDialog(
    BuildContext context,
    PendingMember member,
  ) async {
    Navigator.of(context).pop();
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Accept Request',
      message: 'Accept ${member.firstName} ${member.lastName}?',
    );
    if (confirmed == true) {
      await notifier.acceptRequest(member);
    }
  }

  Future<void> _showDeclineDialog(
    BuildContext context,
    PendingMember member,
  ) async {
    Navigator.of(context).pop();
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Decline Request',
      message: 'Decline ${member.firstName} ${member.lastName}?',
    );
    if (confirmed == true) {
      await notifier.declineRequest(member);
    }
  }
}

Widget _buildLoadingItem() {
  return Padding(
    padding: EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 16),
        Text('Loading more members...', style: TextStyle(color: Colors.grey)),
      ],
    ),
  );
}