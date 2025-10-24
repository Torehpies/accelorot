
// TODO Implement this library.

// lib/frontend/operator/machine_management/machine_management_screen.dart
import 'package:flutter/material.dart';
import 'controllers/machine_controller.dart';
import 'components/machine_action_card.dart';
import 'widgets/add_machine_modal.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/machine_list_widget.dart';

class MachineManagementScreen extends StatefulWidget {
  final String? viewingOperatorId;
  
  const MachineManagementScreen ({super.key, this.viewingOperatorId});

  @override
  State<MachineManagementScreen> createState() =>
      _MachineManagementScreenState();
}

class _MachineManagementScreenState extends State<MachineManagementScreen> {
  late final MachineController _controller;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = MachineController();
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: false,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _controller.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _controller.clearError();
                      _controller.initialize();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Action Cards Row
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

                // Main Container
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
                        Expanded(
                          child: MachineListWidget(controller: _controller),
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
}

