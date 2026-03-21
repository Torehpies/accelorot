import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile_screen/view_model/profile_notifier.dart';
import '../../core/themes/app_theme.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_base.dart';
import '../../core/widgets/bottom_sheets/mobile_bottom_sheet_buttons.dart';

class EditNameDialog extends ConsumerStatefulWidget {
  const EditNameDialog({super.key});

  /// Shows a bottom sheet on mobile (< 800 px) and a dialog on web/desktop.
  static Future<void> show(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >= kTabletBreakpoint;

    if (isDesktop) {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const EditNameDialog(),
      );
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => const EditNameDialog(),
    );
  }

  @override
  ConsumerState<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends ConsumerState<EditNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).profile;
    _firstNameController =
        TextEditingController(text: profile?.firstName ?? '');
    _lastNameController =
        TextEditingController(text: profile?.lastName ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(profileProvider.notifier).updateProfile(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Name updated successfully'),
            backgroundColor: AppColors.green200,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update name: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Shared form content ───────────────────────────────────────────────────

  Widget _buildFormBody() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'First name is required' : null,
            textCapitalization: TextCapitalization.words,
            enabled: !_isLoading,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Last name is required' : null,
            textCapitalization: TextCapitalization.words,
            enabled: !_isLoading,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _save(),
          ),
        ],
      ),
    );
  }

  // ── Shared icon header chip ───────────────────────────────────────────────

  Widget _headerIcon() => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.green100.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.badge_outlined,
          color: AppColors.green100,
          size: 22,
        ),
      );

  // ── Web: AlertDialog ──────────────────────────────────────────────────────

  Widget _buildDialog() {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          _headerIcon(),
          const SizedBox(width: 12),
          const Text(
            'Edit Name',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: _buildFormBody(),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  // ── Mobile: Bottom sheet ──────────────────────────────────────────────────

  Widget _buildBottomSheet() {
    return MobileBottomSheetBase(
      title: 'Edit Name',
      subtitle: 'Update your display name',
      body: _buildFormBody(),
      actions: [
        BottomSheetAction.secondary(
          label: 'Cancel',
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
        BottomSheetAction.primary(
          label: 'Save',
          onPressed: _isLoading ? null : _save,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width >= kTabletBreakpoint;
    return isDesktop ? _buildDialog() : _buildBottomSheet();
  }
}
