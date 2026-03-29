// lib/ui/tasks/bottom_sheets/create_task_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/task_model.dart';
import '../view_model/mobile_tasks_viewmodel.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_base.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_buttons.dart';
import '../../core/ui/app_snackbar.dart';
import '../../core/themes/app_theme.dart';

class CreateTaskBottomSheet extends ConsumerStatefulWidget {
  final String? preSelectedMachineId;
  final String? preSelectedMachineName;

  const CreateTaskBottomSheet({
    super.key,
    this.preSelectedMachineId,
    this.preSelectedMachineName,
  });

  @override
  ConsumerState<CreateTaskBottomSheet> createState() =>
      _CreateTaskBottomSheetState();
}

class _CreateTaskBottomSheetState extends ConsumerState<CreateTaskBottomSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedPriority;
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  String? _titleError;
  String? _descriptionError;
  String? _priorityError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _titleError = null;
      _descriptionError = null;
      _priorityError = null;

      if (_titleController.text.trim().isEmpty) {
        _titleError = 'Title is required';
      } else if (_titleController.text.trim().length < 3) {
        _titleError = 'Title must be at least 3 characters';
      }
      if (_descriptionController.text.trim().isEmpty) {
        _descriptionError = 'Description is required';
      }
      if (_selectedPriority == null) {
        _priorityError = 'Please select a priority level';
      }
    });

    return _titleError == null &&
        _descriptionError == null &&
        _priorityError == null;
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        AppSnackbar.show(
          context,
          message: 'You must be logged in to create a task.',
          type: SnackbarType.error,
        );
        return;
      }

      final userInfo = await ref
          .read(mobileTasksViewModelProvider.notifier)
          .getCurrentUserInfo();

      final teamId = userInfo['teamId'];
      if (teamId == null) {
        AppSnackbar.show(
          context,
          message: 'No team found. Please contact your admin.',
          type: SnackbarType.error,
        );
        return;
      }

      final request = CreateTaskRequest(
        teamId: teamId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        assignedToId: user.uid,
        assignedToName: userInfo['name'] ?? user.email ?? 'Unknown',
        createdById: user.uid,
        createdByName: userInfo['name'] ?? user.email ?? 'Unknown',
        priority: _selectedPriority!,
        machineId: widget.preSelectedMachineId,
        machineName: widget.preSelectedMachineName,
        dueDate: _selectedDueDate,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      await ref
          .read(mobileTasksViewModelProvider.notifier)
          .createTask(request);

      if (mounted) {
        AppSnackbar.show(
          context,
          message: 'Task created successfully!',
          type: SnackbarType.success,
        );
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context,
          message: 'Failed to create task. Please try again.',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.green100,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileBottomSheetBase(
      title: 'Create Task',
      subtitle: 'Add a new task to your list',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            _buildLabel('Task Title', required: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter task title',
                errorText: _titleError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (_) {
                if (_titleError != null) {
                  setState(() => _titleError = null);
                }
              },
            ),
            const SizedBox(height: 16),

            // Description field
            _buildLabel('Description', required: true),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the task...',
                errorText: _descriptionError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (_) {
                if (_descriptionError != null) {
                  setState(() => _descriptionError = null);
                }
              },
            ),
            const SizedBox(height: 16),

            // Priority selector
            _buildLabel('Priority', required: true),
            const SizedBox(height: 6),
            _PrioritySelector(
              selectedPriority: _selectedPriority,
              errorText: _priorityError,
              onChanged: (p) => setState(() {
                _selectedPriority = p;
                _priorityError = null;
              }),
            ),
            const SizedBox(height: 16),

            // Due Date picker
            _buildLabel('Due Date'),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDueDate,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDueDate != null
                          ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                          : 'Select due date (optional)',
                      style: TextStyle(
                        color: _selectedDueDate != null
                            ? Colors.black87
                            : Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedDueDate != null)
                      GestureDetector(
                        onTap: () =>
                            setState(() => _selectedDueDate = null),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes field
            _buildLabel('Notes'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Optional notes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            if (widget.preSelectedMachineName != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.green100.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.green100.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.precision_manufacturing_outlined,
                      size: 16,
                      color: AppColors.green100,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Machine: ${widget.preSelectedMachineName}',
                      style: TextStyle(
                        color: AppColors.green200,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
      actions: [
        BottomSheetAction.secondary(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
        ),
        BottomSheetAction.primary(
          label: 'Create Task',
          isLoading: _isLoading,
          onPressed: _isLoading ? null : _handleSubmit,
        ),
      ],
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(color: Colors.red, fontSize: 13),
          ),
      ],
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final String? selectedPriority;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const _PrioritySelector({
    required this.selectedPriority,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    const options = [
      _PriorityOption(value: 'high', label: 'High', color: Color(0xFFEF4444)),
      _PriorityOption(
        value: 'medium',
        label: 'Medium',
        color: Color(0xFFF59E0B),
      ),
      _PriorityOption(
        value: 'low',
        label: 'Low',
        color: Color(0xFF10B981),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: options.map((option) {
            final isSelected = selectedPriority == option.value;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => onChanged(option.value),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? option.color.withValues(alpha: 0.15)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? option.color : Colors.grey.shade300,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: isSelected ? option.color : Colors.grey[600],
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _PriorityOption {
  final String value;
  final String label;
  final Color color;
  const _PriorityOption({
    required this.value,
    required this.label,
    required this.color,
  });
}
