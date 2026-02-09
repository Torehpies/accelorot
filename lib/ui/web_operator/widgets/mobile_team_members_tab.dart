import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/api/model/team_member/team_member.dart';
import 'package:flutter_application_1/ui/core/widgets/data_card.dart';
import 'package:flutter_application_1/ui/web_operator/view_model/team_members_notifier.dart';
import 'package:flutter_application_1/ui/web_operator/bottom_sheets/team_member_view_sheet.dart';
import 'package:flutter_application_1/ui/web_operator/bottom_sheets/team_member_edit_sheet.dart';
import 'package:flutter_application_1/utils/get_operator_status_style.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileTeamMembersTab extends ConsumerStatefulWidget {
  const MobileTeamMembersTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MobileTeamMembersState();
}

class _MobileTeamMembersState extends ConsumerState<MobileTeamMembersTab>
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
      ref.read(teamMembersProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final notifier = ref.read(teamMembersProvider.notifier);
    return _MembersList(
      notifier: notifier,
      scrollController: _scrollController,
    );
  }
}

class _MembersList extends ConsumerWidget {
  final TeamMembersNotifier notifier;
  final ScrollController scrollController;

  const _MembersList({required this.notifier, required this.scrollController});

  void _showEditSheet(
    BuildContext context,
    TeamMembersNotifier notifier,
    TeamMember member,
  ) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TeamMemberEditSheet(
        member: member,
        onUpdate: notifier.updateOperator,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(teamMembersProvider);
    if (state.isLoading && state.items.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    if (state.items.isEmpty && !state.isLoading) {
      return Center(
        child: Text(
          'No team members found',
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
        final member = state.items[index];
        final style = getStatusStyle(member.status.value);
        return DataCard<TeamMember>(
          data: member,
          icon: Icons.person,
          iconColor: style.textColor,
          iconBgColor: style.color,
          title: "${member.lastName}, ${member.firstName}",
          category: _getStatusLabel(member.status.value),
          status: member.email,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => TeamMemberViewSheet(
                member: member,
                onEdit: () => _showEditSheet(context, notifier, member),
              ),
            );
          },
        );
      },
    );
  }

  String _getStatusLabel(String statusValue) {
    return statusValue.substring(0, 1).toUpperCase() + statusValue.substring(1);
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