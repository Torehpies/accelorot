// lib/ui/web_operator/widgets/accept_operators_card.dart

import 'package:flutter/material.dart';
import '../view_model/pending_members_view_model.dart';
import '../../../data/services/firebase/firebase_operator_service.dart';
import '../../../data/repositories/operator_repository.dart';
import '../../core/ui/theme_constants.dart';
import '../../core/ui/operator_dialogs.dart';

class AcceptOperatorsScreen extends StatefulWidget {
  final String teamId; 
  
  const AcceptOperatorsScreen({
    super.key,
    required this.teamId,
  });

  @override
  State<AcceptOperatorsScreen> createState() => _AcceptOperatorsScreenState();
}

class _AcceptOperatorsScreenState extends State<AcceptOperatorsScreen> {
  late PendingMembersViewModel _controller;

  @override
  void initState() {
    super.initState();
    // Create the service, repository, and viewmodel with proper dependencies
    final service = FirebaseOperatorService();
    final repository = OperatorRepositoryImpl(service);
    _controller = PendingMembersViewModel(
      repository: repository,
      teamId: widget.teamId, // Use teamId from widget
    );
    _controller.addListener(_onControllerUpdate);
    _controller.loadPendingMembers();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _acceptInvitation(int index) async {
    final member = _controller.pendingMembers[index];
    final memberName = member['name'] as String? ?? 'Unknown'; // Extract name from Map
    
    final success = await _controller.acceptInvitation(index);

    if (!mounted) return;

    if (success) {
      OperatorDialogs.showSuccessSnackbar(
        context,
        '✅ Accepted $memberName to the team',
      );
    } else {
      OperatorDialogs.showErrorSnackbar(context, 'Error accepting invitation');
    }
  }

  Future<void> _declineInvitation(int index) async {
    final member = _controller.pendingMembers[index];
    final memberName = member['name'] as String? ?? 'Unknown'; // Extract name from Map
    
    final success = await _controller.declineInvitation(index);

    if (!mounted) return;

    if (success) {
      OperatorDialogs.showWarningSnackbar(
        context,
        'Declined invitation from $memberName',
      );
    } else {
      OperatorDialogs.showErrorSnackbar(context, 'Error declining invitation');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(ThemeConstants.spacing24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 500),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius24),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(ThemeConstants.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                              color: Colors.black87,
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
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: ThemeConstants.spacing16),
            const Text(
              'Error loading pending members',
              style: TextStyle(
                fontSize: ThemeConstants.fontSize16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
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
              onPressed: () => _controller.loadPendingMembers(),
              icon: const Icon(Icons.refresh, size: 16.0),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.tealShade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (!_controller.hasPendingMembers) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: ThemeConstants.greyShade300,
            ),
            const SizedBox(height: ThemeConstants.spacing16),
            Text(
              'No pending invitations',
              style: TextStyle(
                fontSize: ThemeConstants.fontSize16,
                fontWeight: FontWeight.bold,
                color: ThemeConstants.greyShade600,
              ),
            ),
            const SizedBox(height: ThemeConstants.spacing8),
            Text(
              'All operators have been accepted or declined',
              style: TextStyle(
                fontSize: ThemeConstants.fontSize13,
                color: ThemeConstants.greyShade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(ThemeConstants.spacing20),
      itemCount: _controller.pendingMembers.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: ThemeConstants.spacing12),
      itemBuilder: (context, index) {
        final member = _controller.pendingMembers[index];
        return _buildPendingMemberCard(member, index);
      },
    );
  }

  Widget _buildPendingMemberCard(Map<String, dynamic> member, int index) {
    // Extract data from Map
    final name = member['name'] as String? ?? 'Unknown';
    final email = member['email'] as String? ?? '';
    final requestedAt = member['requestedAt'] as DateTime?;
    
    String requestedText = 'Requested: ';
    if (requestedAt != null) {
      final difference = DateTime.now().difference(requestedAt);
      if (difference.inDays > 0) {
        requestedText += '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        requestedText += '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        requestedText += '${difference.inMinutes}m ago';
      } else {
        requestedText += 'Just now';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacing16),
        child: Row(
          children: [
            Container(
              width: ThemeConstants.avatarSize48,
              height: ThemeConstants.avatarSize48,
              decoration: BoxDecoration(
                color: ThemeConstants.tealShade100,
                borderRadius: BorderRadius.circular(
                  ThemeConstants.borderRadius12,
                ),
              ),
              child: Icon(
                Icons.person,
                color: ThemeConstants.tealShade700,
                size: ThemeConstants.iconSize24,
              ),
            ),
            const SizedBox(width: ThemeConstants.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: ThemeConstants.fontSize14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: ThemeConstants.spacing4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: ThemeConstants.fontSize12,
                      color: ThemeConstants.greyShade600,
                    ),
                  ),
                  const SizedBox(height: ThemeConstants.spacing4),
                  Text(
                    requestedText,
                    style: TextStyle(
                      fontSize: ThemeConstants.fontSize11,
                      color: ThemeConstants.greyShade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: ThemeConstants.spacing12),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () => _acceptInvitation(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.tealShade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeConstants.spacing12,
                        vertical: ThemeConstants.spacing8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ThemeConstants.borderRadius10,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(fontSize: ThemeConstants.fontSize12),
                    ),
                  ),
                ),
                const SizedBox(height: ThemeConstants.spacing8),
                SizedBox(
                  width: 100,
                  child: OutlinedButton(
                    onPressed: () => _declineInvitation(index),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeConstants.greyShade700,
                      side: BorderSide(color: ThemeConstants.greyShade300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: ThemeConstants.spacing12,
                        vertical: ThemeConstants.spacing8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          ThemeConstants.borderRadius10,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(fontSize: ThemeConstants.fontSize12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
