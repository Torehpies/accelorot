import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/pending_members_view_model.dart';
import '../../../data/providers/operator_providers.dart';
import '../../core/ui/theme_constants.dart';
import '../../core/ui/operator_dialogs.dart';

class AcceptOperatorsScreen extends ConsumerStatefulWidget {
  final String teamId;

  const AcceptOperatorsScreen({
    super.key,
    required this.teamId,
  });

  @override
  ConsumerState<AcceptOperatorsScreen> createState() =>
      _AcceptOperatorsScreenState();
}

class _AcceptOperatorsScreenState
    extends ConsumerState<AcceptOperatorsScreen> {
  late PendingMembersViewModel _controller;

  @override
  void initState() {
    super.initState();

    final repository = ref.read(operatorRepositoryProvider);

    _controller = PendingMembersViewModel(
      repository: repository,
      teamId: widget.teamId,
    );

    _controller.addListener(_onUpdate);
    _controller.loadPendingMembers();
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  // ───────────────────────── Header ─────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.spacing24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Accept Operators',
                style: TextStyle(
                  fontSize: ThemeConstants.fontSize20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: ThemeConstants.spacing4),
              Text(
                'Review and manage pending operator invitations',
                style: TextStyle(
                  fontSize: ThemeConstants.fontSize13,
                  color: ThemeConstants.greyShade600,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: ThemeConstants.greyShade100,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Content ─────────────────────────
  Widget _buildContent() {
    if (_controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.error != null) {
      return _buildErrorState();
    }

    if (!_controller.hasPendingMembers) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(ThemeConstants.spacing20),
      itemCount: _controller.pendingMembers.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: ThemeConstants.spacing12),
      itemBuilder: (_, index) =>
          _buildPendingMemberCard(_controller.pendingMembers[index], index),
    );
  }

  // ───────────────────────── Error ─────────────────────────
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 48, color: Colors.red.shade300),
          const SizedBox(height: ThemeConstants.spacing16),
          const Text(
            'Error loading pending members',
            style: TextStyle(
              fontSize: ThemeConstants.fontSize16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: ThemeConstants.spacing8),
          Text(
            _controller.error ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: ThemeConstants.fontSize13,
              color: ThemeConstants.greyShade600,
            ),
          ),
          const SizedBox(height: ThemeConstants.spacing16),
          ElevatedButton.icon(
            onPressed: _controller.loadPendingMembers,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Empty ─────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined,
              size: 64, color: ThemeConstants.greyShade300),
          const SizedBox(height: ThemeConstants.spacing16),
          const Text(
            'No pending invitations',
            style: TextStyle(
              fontSize: ThemeConstants.fontSize16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Card ─────────────────────────
  Widget _buildPendingMemberCard(
    Map<String, dynamic> member,
    int index,
  ) {
    final name = member['name'] as String? ?? 'Unknown';
    final email = member['email'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(ThemeConstants.spacing16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(ThemeConstants.borderRadius16),
      ),
      child: Row(
        children: [
          const Icon(Icons.person),
          const SizedBox(width: ThemeConstants.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: ThemeConstants.spacing4),
                Text(email,
                    style: TextStyle(
                        color: ThemeConstants.greyShade600)),
              ],
            ),
          ),
          const SizedBox(width: ThemeConstants.spacing12),
          Column(
            children: [
              ElevatedButton(
                onPressed: () => _acceptInvitation(index),
                child: const Text('Accept'),
              ),
              const SizedBox(height: ThemeConstants.spacing8),
              OutlinedButton(
                onPressed: () => _declineInvitation(index),
                child: const Text('Decline'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Actions ─────────────────────────
  Future<void> _acceptInvitation(int index) async {
    final name =
        _controller.pendingMembers[index]['name'] ?? 'Unknown';

    final success = await _controller.acceptInvitation(index);

    if (!mounted) return;

    success
        ? OperatorDialogs.showSuccessSnackbar(
            context,
            '✅ Accepted $name to the team',
          )
        : OperatorDialogs.showErrorSnackbar(
            context,
            'Error accepting invitation',
          );
  }

  Future<void> _declineInvitation(int index) async {
    final name =
        _controller.pendingMembers[index]['name'] ?? 'Unknown';

    final success = await _controller.declineInvitation(index);

    if (!mounted) return;

    success
        ? OperatorDialogs.showWarningSnackbar(
            context,
            'Declined invitation from $name',
          )
        : OperatorDialogs.showErrorSnackbar(
            context,
            'Error declining invitation',
          );
  }

  // ───────────────────────── Build ─────────────────────────
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(ThemeConstants.spacing24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(ThemeConstants.borderRadius24),
        ),
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }
}
