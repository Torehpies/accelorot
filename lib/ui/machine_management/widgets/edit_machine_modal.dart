import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/machine_model.dart';
import '../../../data/models/operator_model.dart';
import '../../../data/providers/operator_providers.dart';
import '../view_model/admin_machine_notifier.dart';
import 'user_selector_dropdown.dart';
import 'status_dropdown.dart';
import 'success_dialog.dart';

class EditMachineModal extends ConsumerStatefulWidget {
  final MachineModel machine;
  final String teamId;

  const EditMachineModal({
    super.key,
    required this.machine,
    required this.teamId,
  });

  @override
  ConsumerState<EditMachineModal> createState() => _EditMachineModalState();
}

class _EditMachineModalState extends ConsumerState<EditMachineModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _machineNameController;
  late MachineStatus _selectedStatus;
  late List<String> _selectedUserIds;
  List<OperatorModel> _users = [];
  bool _isSubmitting = false;
  bool _isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    _machineNameController = TextEditingController(
      text: widget.machine.machineName,
    );
    _selectedStatus = widget.machine.status;
    _selectedUserIds = List.from(widget.machine.assignedUserIds);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final operators = await ref
          .read(operatorRepositoryProvider)
          .getOperators(widget.teamId);
      
      if (mounted) {
        setState(() {
          _users = operators.where((o) => !o.isArchived).toList();
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUsers = false);
      }
    }
  }

  @override
  void dispose() {
    _machineNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final notifier = ref.read(adminMachineProvider.notifier);
      
      await notifier.updateMachine(
        teamId: widget.teamId,
        machineId: widget.machine.machineId,
        machineName: _machineNameController.text.trim(),
        status: _selectedStatus,
        assignedUserIds: _selectedUserIds,
      );

      if (mounted) {
        Navigator.of(context).pop();
        await SuccessDialog.show(context, 'Machine updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUsers) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Edit Machine',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new machine procured from the manufacturer.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),

            // Machine Name
            const Text(
              'Machine Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _machineNameController,
              decoration: InputDecoration(
                hintText: 'Enter Machine Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a machine name';
                }
                return null;
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),

            // Status
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            StatusDropdown(
              status: _selectedStatus,
              onChanged: (status) {
                setState(() => _selectedStatus = status);
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),

            // Machine ID (read-only)
            const Text(
              'Machine ID',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: widget.machine.machineId,
              decoration: InputDecoration(
                suffixIcon: const Icon(Icons.lock, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              enabled: false,
            ),
            const SizedBox(height: 16),

            // User
            const Text(
              'User',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            UserSelectorDropdown(
              users: _users,
              selectedUserIds: _selectedUserIds,
              onSelectionChanged: (selected) {
                setState(() => _selectedUserIds = selected);
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}