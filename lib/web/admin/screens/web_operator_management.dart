// lib/screens/operator_management_screen.dart

import 'package:flutter/material.dart';
import '../controllers/operator_management_controller.dart';
import '../widgets/operator_action_card.dart';
import '../widgets/operator_list_item.dart';
import '../widgets/operator_detail_panel.dart';
import '../widgets/operator_empty_state.dart';
import '../widgets/operator_error_state.dart';
import '../widgets/operator_list_header.dart';
import '../../utils/operator_dialogs.dart';
import '../../utils/theme_constants.dart';
import '../widgets/accept_operators_card.dart';
import '../../../web/admin/widgets/add_operator_screen.dart';


class OperatorManagementScreen extends StatefulWidget {
  const OperatorManagementScreen({super.key});

  @override
  State<OperatorManagementScreen> createState() => _OperatorManagementScreenState();
}

class _OperatorManagementScreenState extends State<OperatorManagementScreen> {
  late OperatorManagementController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OperatorManagementController();
    _controller.addListener(_onControllerUpdate);
    _controller.loadOperators();
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

  void _showAddOperatorDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConstants.borderRadius12),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 450, maxHeight: 800),
          child: AddOperatorScreen(),
        ),
      ),
    ).then((_) => _controller.loadOperators());
  }

  void _showAcceptOperatorDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => const AcceptOperatorsScreen(),
    ).then((_) => _controller.loadOperators());
  }

  Future<void> _handleArchive() async {
    final operator = _controller.selectedOperator;
    if (operator == null) return;

    final confirm = await OperatorDialogs.showArchiveConfirmation(
      context,
      operator.name,
    );

    if (confirm != true || !mounted) return;

    final success = await _controller.archiveOperator(operator);
    if (!mounted) return;

    if (success) {
      _controller.clearSelectedOperator();
      OperatorDialogs.showSuccessSnackbar(
        context,
        '${operator.name} archived successfully',
      );
    } else {
      OperatorDialogs.showErrorSnackbar(
        context,
        'Error archiving operator',
      );
    }
  }

  Future<void> _handleRestore() async {
    final operator = _controller.selectedOperator;
    if (operator == null) return;

    if (operator.hasLeft) {
      OperatorDialogs.showWarningSnackbar(
        context,
        'Cannot restore operators who have left the team',
      );
      return;
    }

    final success = await _controller.restoreOperator(operator);
    if (!mounted) return;

    if (success) {
      _controller.clearSelectedOperator();
      OperatorDialogs.showSuccessSnackbar(
        context,
        '${operator.name} restored successfully',
      );
    } else {
      OperatorDialogs.showErrorSnackbar(
        context,
        'Error restoring operator',
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.greyShade50,
      appBar: AppBar(
        backgroundColor: ThemeConstants.tealShade700,
        elevation: 0,
        title: const Text(
          'Operator Management',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacing12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action Cards Row - Always visible
            SizedBox(
              height: 100,
              child: _buildActionCards(),
            ),
            const SizedBox(height: ThemeConstants.spacing12),

            // Main Content Area
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side - Operator List
                  Expanded(
                    child: _buildOperatorList(),
                  ),
                  // Spacing
                  if (_controller.selectedOperator != null)
                    const SizedBox(width: ThemeConstants.spacing12),
                  // Right Side - Detail Panel (full height)
                  if (_controller.selectedOperator != null)
                    SizedBox(
                      width: 320,
                      child: OperatorDetailPanel(
                        operator: _controller.selectedOperator!,
                        onClose: () => _controller.clearSelectedOperator(),
                        onArchive: _handleArchive,
                        onRestore: _handleRestore,
                        showArchived: _controller.showArchived,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards() {
    return Row(
      children: [
        Expanded(
          child: OperatorActionCard(
            icon: Icons.archive,
            label: 'Archive',
            count: _controller.archivedCount,
            onPressed: () => _controller.setShowArchived(true),
            showCountBelow: true,
            iconBackgroundColor: ThemeConstants.orangeShade50,
            iconColor: ThemeConstants.orangeShade600,
            isActive: _controller.showArchived,
          ),
        ),
        const SizedBox(width: ThemeConstants.spacing12),
        Expanded(
          child: OperatorActionCard(
            icon: Icons.person_add_alt_1,
            label: 'Add Operator',
            count: null,
            onPressed: _showAddOperatorDialog,
            showCountBelow: false,
            iconBackgroundColor: ThemeConstants.blueShade50,
            iconColor: ThemeConstants.blueShade600,
          ),
        ),
        const SizedBox(width: ThemeConstants.spacing12),
        Expanded(
          child: OperatorActionCard(
            icon: Icons.check_circle,
            label: 'Accept Operator',
            count: null,
            onPressed: _showAcceptOperatorDialog,
            showCountBelow: false,
            iconBackgroundColor: ThemeConstants.greenShade50,
            iconColor: ThemeConstants.greenShade600,
          ),
        ),
        const SizedBox(width: ThemeConstants.spacing12),
        Expanded(
          child: OperatorActionCard(
            icon: Icons.people,
            label: 'Active Operators',
            count: _controller.activeCount,
            onPressed: () => _controller.setShowArchived(false),
            showCountBelow: true,
            isActive: !_controller.showArchived,
          ),
        ),
      ],
    );
  }

  Widget _buildOperatorList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius20),
        border: Border.all(color: ThemeConstants.greyShade300, width: 1.0),
      ),
      child: Column(
        children: [
          // Header
          OperatorListHeader(
            showArchived: _controller.showArchived,
            searchQuery: _controller.searchQuery,
            onSearchChanged: (value) => _controller.setSearchQuery(value),
            onRefresh: () => _controller.loadOperators(),
            onBack: _controller.showArchived 
                ? () => _controller.setShowArchived(false) 
                : null,
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: _buildListContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    if (_controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.error != null) {
      return OperatorErrorState(
        error: _controller.error!,
        onRetry: () => _controller.loadOperators(),
      );
    }

    final displayList = _controller.filteredOperators;

    if (displayList.isEmpty) {
      return OperatorEmptyState(
        isSearching: _controller.searchQuery.isNotEmpty,
        isArchived: _controller.showArchived,
        searchQuery: _controller.searchQuery,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConstants.spacing12,
        vertical: ThemeConstants.spacing8,
      ),
      itemCount: displayList.length,
      separatorBuilder: (context, index) => const SizedBox(height: ThemeConstants.spacing8),
      itemBuilder: (context, index) {
        final operator = displayList[index];
        final isSelected = _controller.selectedOperator?.id == operator.id;

        return OperatorListItem(
          operator: operator,
          isSelected: isSelected,
          onTap: () => _controller.setSelectedOperator(operator),
        );
      },
    );
  }
}