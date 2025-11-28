// lib/screens/operator_management_screen.dart

import 'package:flutter/material.dart';
import '../controllers/operator_management_controller.dart';
import '../widgets/operator_action_card.dart';
import '../widgets/operator_list_item.dart';
import '../widgets/operator_detail_panel.dart';
import '../widgets/operator_empty_state.dart';
import '../widgets/operator_error_state.dart';
import '../../../ui/core/ui/admin_search_bar.dart';
import '../../utils/operator_dialogs.dart';
import '../../utils/theme_constants.dart';
import '../widgets/accept_operators_card.dart';
import '../../../web/admin/widgets/add_operator_screen.dart';
import '../../../ui/core/ui/admin_app_bar.dart';

class OperatorManagementScreen extends StatefulWidget {
  const OperatorManagementScreen({super.key});

  @override
  State<OperatorManagementScreen> createState() =>
      _OperatorManagementScreenState();
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
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 800),
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
      OperatorDialogs.showErrorSnackbar(context, 'Error archiving operator');
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
      OperatorDialogs.showErrorSnackbar(context, 'Error restoring operator');
    }
  }

  Future<void> _handleRemovePermanently() async {
    final operator = _controller.selectedOperator;
    if (operator == null) return;

    final confirm = await OperatorDialogs.showRemovePermanentlyConfirmation(
      context,
      operator.name,
    );

    if (confirm != true || !mounted) return;

    final success = await _controller.removeOperatorPermanently(operator);
    if (!mounted) return;

    if (success) {
      _controller.clearSelectedOperator();
      OperatorDialogs.showSuccessSnackbar(
        context,
        '${operator.name} has been removed permanently',
      );
    } else {
      OperatorDialogs.showErrorSnackbar(context, 'Failed to remove operator');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const AdminAppBar(
        title: 'Operator Management',
      ),
      body: Padding(
        padding: const EdgeInsets.all(ThemeConstants.spacing12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Action Cards Row - Only show Add and Accept
            SizedBox(height: 100, child: _buildActionCards()),
            const SizedBox(height: ThemeConstants.spacing12),

            // Main Content Area
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Side - Operator List with integrated header and search
                  Expanded(child: _buildOperatorList()),
                  // Spacing
                  if (_controller.selectedOperator != null)
                    const SizedBox(width: ThemeConstants.spacing12),
                  // Right Side - Detail Panel
                  if (_controller.selectedOperator != null)
                    SizedBox(
                      width: 320,
                      child: OperatorDetailPanel(
                        operator: _controller.selectedOperator!,
                        onClose: () => _controller.clearSelectedOperator(),
                        onArchive: _handleArchive,
                        onRestore: _handleRestore,
                        onRemovePermanently: _handleRemovePermanently,
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
            showCountBelow: false,
            iconBackgroundColor: ThemeConstants.orangeShade50,
            iconColor: ThemeConstants.orangeShade600,
            isActive: false,
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
            label: 'Total Operators',
            count: _controller.activeCount + _controller.archivedCount,
            onPressed: null,
            showCountBelow: true,
            iconBackgroundColor: ThemeConstants.tealShade50,
            iconColor: ThemeConstants.tealShade600,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with toggle and search
          _buildListHeader(),
          const Divider(height: 1),
          Expanded(child: _buildListContent()),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.all(ThemeConstants.spacing16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _controller.showArchived ? 'Archived Operators' : 'Active Operators',
              style: TextStyle(
                fontSize: ThemeConstants.fontSize18,
                fontWeight: FontWeight.bold,
                color: ThemeConstants.tealShade600,
              ),
            ),
          ),
          // Use existing AdminSearchBar widget
          AdminSearchBar(
            searchQuery: _controller.searchQuery,
            onSearchChanged: (value) => _controller.setSearchQuery(value),
            onRefresh: () => _controller.loadOperators(),
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
      separatorBuilder: (context, index) =>
          const SizedBox(height: ThemeConstants.spacing8),
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