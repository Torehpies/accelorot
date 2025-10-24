// lib/frontend/operator/machine_management/admin_machine/admin_machine_screen.dart

import 'package:flutter/material.dart';
import 'controllers/admin_machine_controller.dart';
import '../components/machine_action_card.dart';
import 'widgets/add_machine_modal.dart';
import '../widgets/search_bar_widget.dart';
import 'widgets/admin_machine_list.dart';

class AdminMachineScreen extends StatefulWidget {
  final String? viewingOperatorId;
  
  const AdminMachineScreen ({super.key, this.viewingOperatorId});

  @override
  State<AdminMachineScreen> createState() => _AdminMachineScreenState();
}

class _AdminMachineScreenState extends State<AdminMachineScreen> {
  late final AdminMachineController _controller;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AdminMachineController();
    _controller.initialize();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _showAddMachineModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddMachineModal(controller: _controller),
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
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: false,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action Cards Row - Always Visible
                Row(
                  children: [
                    Expanded(
                      child: MachineActionCard(
                        icon: Icons.archive,
                        label: 'Archive',
                        onPressed: () => _controller.setShowArchived(true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MachineActionCard(
                        icon: Icons.add_circle_outline,
                        label: 'Add Machine',
                        onPressed: _showAddMachineModal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Toggle between archived and active
                if (_controller.showArchived)
                  TextButton.icon(
                    onPressed: () => _controller.setShowArchived(false),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Back to Active Machines'),
                    style: TextButton.styleFrom(foregroundColor: Colors.teal),
                  ),
                const SizedBox(height: 8),

                // Main Container - Always Visible
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!, width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SearchBarWidget(
                            onSearchChanged: _controller.setSearchQuery,
                            onClear: _controller.clearSearch,
                            focusNode: _searchFocusNode,
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Text(
                                _controller.showArchived
                                    ? 'Archived Machines'
                                    : 'List of Machines',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Content with Error/Loading States Inside
                        Expanded(
                          child: _buildContent(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    // Loading State - inside container
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error State - inside container
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
                style: TextStyle(color: Colors.red.shade700, fontSize: 14),
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

    // Content - Machine List
    return AdminMachineList(controller: _controller);
  }
}