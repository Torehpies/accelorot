import 'package:flutter/material.dart';
import '../controllers/admin_machine_controller.dart';
import '../widgets/add_machine_modal.dart';
import '../widgets/admin_machine_list.dart';
import '../widgets/operator_search_bar.dart';

class ThemeConstants {
  static const double spacing12 = 12.0;
  static const double spacing8 = 8.0;
  static const double borderRadius20 = 20.0;
  static const double borderRadius12 = 12.0;
  static final Color greyShade300 = Colors.grey[300]!;
  static final Color tealShade700 = Colors.teal.shade700;
}

class WebMachineManagement extends StatefulWidget {

  
  const WebMachineManagement({super.key, this.viewingOperatorId});
  final String? viewingOperatorId;

  @override
  State<WebMachineManagement> createState() => _WebMachineManagementState();
}

class _WebMachineManagementState extends State<WebMachineManagement> {
  late final AdminMachineController _controller;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AdminMachineController();
    _controller.addListener(_onControllerUpdate);
    _controller.initialize();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showAddMachineModal() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: AddMachineModal(controller: _controller),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Machine Management',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: ThemeConstants.tealShade700,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.spacing12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟩 ACTION CARDS ROW
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.archive,
                        label: 'Archive',
                        count: null,
                        onPressed: () => _controller.setShowArchived(true),
                        iconBackgroundColor: Colors.orange[50]!,
                        iconColor: Colors.orange.shade700,
                      ),
                    ),
                    const SizedBox(width: ThemeConstants.spacing12),
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.add_circle_outline,
                        label: 'Add Machine',
                        count: null,
                        onPressed: _showAddMachineModal,
                        iconBackgroundColor: Colors.blue[50]!,
                        iconColor: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: ThemeConstants.spacing12),
                    Expanded(
                      child: _buildActionCard(
                        icon: Icons.devices,
                        label: 'Total Machines',
                        count: _controller.filteredMachines.length,
                        onPressed: () => _controller.setShowArchived(false),
                        iconBackgroundColor: Colors.teal[50]!,
                        iconColor: Colors.teal.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ThemeConstants.spacing12),

              // 🟦 MAIN CONTENT CONTAINER — SEARCH BAR INSIDE
              Expanded(
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(ThemeConstants.borderRadius20),
                    border: Border.all(
                      color: ThemeConstants.greyShade300,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      // 🔹 HEADER + SEARCH BAR IN SAME ROW
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ThemeConstants.spacing12,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            // LEFT: Section Title
                            Text(
                              _controller.showArchived
                                  ? 'Archived Machines'
                                  : 'Active Machines',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),

                            const Spacer(),

                            // RIGHT: Search Bar + Refresh Button
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: OperatorSearchBar(
                                      searchQuery: _controller.searchQuery,
                                      onSearchChanged: _controller.setSearchQuery,
                                       onRefresh: _controller.initialize,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      // MACHINE LIST
                      Expanded(
                        child: _buildContent(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _controller.errorMessage!,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _controller.clearError();
                  _controller.initialize();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AdminMachineList(controller: _controller);
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required int? count,
    required VoidCallback onPressed,
    required Color iconBackgroundColor,
    required Color iconColor,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ThemeConstants.greyShade300, width: 1.0),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (count != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}