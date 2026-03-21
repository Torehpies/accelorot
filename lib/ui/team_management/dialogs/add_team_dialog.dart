// lib/ui/team_management/dialogs/add_team_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/providers/auth_providers.dart';
import 'package:flutter_application_1/data/services/api/model/team/team.dart';
import 'package:flutter_application_1/ui/core/ui/app_snackbar.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/base_dialog.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/dialog_action.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/dialog_fields.dart';
import 'package:flutter_application_1/ui/core/widgets/dialog/web_confirmation_dialog.dart';
import 'package:flutter_application_1/ui/team_management/view_model/add_team_notifier.dart';
import 'package:flutter_application_1/ui/team_management/view_model/team_management_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddTeamDialog extends ConsumerStatefulWidget {
  const AddTeamDialog({super.key});

  @override
  ConsumerState<AddTeamDialog> createState() => _AddTeamDialogState();
}

class _AddTeamDialogState extends ConsumerState<AddTeamDialog> {
  // ── Controllers
  final _teamNameController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _streetController = TextEditingController();
  final _barangayController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();

  // ── Per-field error state
  String? _teamNameError;
  String? _houseNumberError;
  String? _streetError;
  String? _barangayError;
  String? _cityError;
  String? _regionError;

  // ── Derived helpers
  bool get _isDirty =>
      _teamNameController.text.isNotEmpty ||
      _houseNumberController.text.isNotEmpty ||
      _streetController.text.isNotEmpty ||
      _barangayController.text.isNotEmpty ||
      _cityController.text.isNotEmpty ||
      _regionController.text.isNotEmpty;

  bool get _hasValidInput =>
      _teamNameController.text.isNotEmpty &&
      _houseNumberController.text.isNotEmpty &&
      _streetController.text.isNotEmpty &&
      _barangayController.text.isNotEmpty &&
      _cityController.text.isNotEmpty &&
      _regionController.text.isNotEmpty;

  bool get _hasAnyError =>
      _teamNameError != null ||
      _houseNumberError != null ||
      _streetError != null ||
      _barangayError != null ||
      _cityError != null ||
      _regionError != null;

  // ── Submit-time validation — preserves all original validator rules
  bool _validate() {
    final teamName = _teamNameController.text.trim();
    final houseNumber = _houseNumberController.text.trim();
    final street = _streetController.text.trim();
    final barangay = _barangayController.text.trim();
    final city = _cityController.text.trim();
    final region = _regionController.text.trim();

    setState(() {
      _teamNameError = teamName.isEmpty
          ? 'Team Name is required'
          : teamName.length < 3
              ? 'Team name must be at least 3 characters'
              : null;

      _houseNumberError = houseNumber.isEmpty
          ? 'This field is required'
          : houseNumber.length < 3
              ? 'This field must be at least 4 characters'
              : null;

      _streetError = street.isEmpty
          ? 'This field is required'
          : street.length < 4
              ? 'This field must be at least 4 characters'
              : null;

      _barangayError = barangay.isEmpty
          ? 'This field is required'
          : barangay.length > 5
              ? 'This field has a maximum of 5 characters'
              : null;

      _cityError = city.isEmpty
          ? 'This field is required'
          : city.length < 4
              ? 'This field must be at least 4 characters'
              : null;

      _regionError = region.isEmpty
          ? 'This field is required'
          : region.length < 3
              ? 'This field must be at least 3 characters'
              : null;
    });

    return _teamNameError == null &&
        _houseNumberError == null &&
        _streetError == null &&
        _barangayError == null &&
        _cityError == null &&
        _regionError == null;
  }

  // ── Cancel handler
  Future<void> _handleCancel() async {
    if (_isDirty) {
      final result = await WebConfirmationDialog.show(
        context,
        title: 'Discard Changes',
        message: 'You have unsaved changes. Are you sure you want to discard them?',
        confirmLabel: 'Discard',
        cancelLabel: 'Keep Editing',
        confirmIsDestructive: true,
      );
      if (result == ConfirmResult.confirmed && context.mounted) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  // ── Submit handler
  Future<void> _handleSubmit() async {
    if (!_validate()) return;

    final result = await WebConfirmationDialog.show(
      context,
      title: 'Add Team',
      message: 'Are you sure you want to create this team?',
      confirmLabel: 'Add Team',
      cancelLabel: 'Go Back',
      confirmIsDestructive: false,
    );

    if (result != ConfirmResult.confirmed) return;
    if (!context.mounted) return;

    _addTeam();
  }

  // ── Business logic — unchanged from original
  void _addTeam() {
    final teamName = _teamNameController.text.trim();
    final houseNumber = _houseNumberController.text.trim();
    final street = _streetController.text.trim();
    final barangay = 'BRGY. ${_barangayController.text.trim()}';
    final city = _cityController.text.trim();
    final region = _regionController.text.trim();

    final address = [
      houseNumber,
      street,
      barangay,
      city,
      region,
    ].where((s) => s.isNotEmpty).join(', ');

    final appUserId = ref.read(authUserProvider).value!.uid;

    final Team team = Team(
      teamName: teamName,
      houseNumber: houseNumber,
      street: street,
      barangay: barangay,
      city: city,
      region: region,
      address: address,
      createdAt: DateTime.now(),
      createdBy: appUserId,
    );

    ref.read(addTeamProvider.notifier).addTeam(team);
    ref.read(teamManagementProvider.notifier).refresh();
  }

  // ── Lifecycle
  @override
  void dispose() {
    _teamNameController.dispose();
    _houseNumberController.dispose();
    _streetController.dispose();
    _barangayController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  // ── Build
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addTeamProvider);

    ref.listen<AsyncValue<void>>(addTeamProvider, (_, next) {
      if (next is AsyncData) {
        if (context.mounted) {
          Navigator.of(context).pop();
          AppSnackbar.success(context, 'Team added successfully!');
        }
      } else if (next is AsyncError) {
        if (context.mounted) {
          AppSnackbar.error(context, next.error.toString());
        }
      }
    });

    return BaseDialog(
      title: 'Add Team',
      subtitle: 'Create a new team.',
      canClose: !state.isLoading,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Team Name
          InputField(
            label: 'Team Name',
            controller: _teamNameController,
            hintText: 'Team',
            errorText: _teamNameError,
            enabled: !state.isLoading,
            required: true,
            keyboardType: TextInputType.text,
            onChanged: (_) => setState(() => _teamNameError = null),
          ),
          const SizedBox(height:  12),

          // ── House / Lot / Block
          InputField(
            label: 'House/Lot/Block',
            controller: _houseNumberController,
            hintText: '1111 / Lot 10 Blk 10',
            errorText: _houseNumberError,
            enabled: !state.isLoading,
            required: true,
            keyboardType: TextInputType.streetAddress,
            onChanged: (_) => setState(() => _houseNumberError = null),
          ),
          const SizedBox(height:  12),

          // ── Street / Road / Subd.
          InputField(
            label: 'Street/Road/Subd.',
            controller: _streetController,
            hintText: 'Libra St. / Zabarte Road / Luisa Subd.',
            errorText: _streetError,
            enabled: !state.isLoading,
            required: true,
            keyboardType: TextInputType.streetAddress,
            onChanged: (_) => setState(() => _streetError = null),
          ),
          const SizedBox(height:  12),

          // ── Barangay
          InputField(
            label: 'Barangay',
            controller: _barangayController,
            hintText: '178 / 176-E',
            errorText: _barangayError,
            enabled: !state.isLoading,
            required: true,
            keyboardType: TextInputType.text,
            onChanged: (_) => setState(() => _barangayError = null),
          ),
          const SizedBox(height:  12),

          // ── City
          InputField(
            label: 'City',
            controller: _cityController,
            hintText: 'Caloocan City',
            errorText: _cityError,
            enabled: !state.isLoading,
            required: true,
            keyboardType: TextInputType.text,
            onChanged: (_) => setState(() => _cityError = null),
          ),
          const SizedBox(height:  12),

          // ── Region
          InputField(
            label: 'Region',
            controller: _regionController,
            hintText: 'Region 1 / NCR',
            errorText: _regionError,
            enabled: !state.isLoading,
            required: true,
            keyboardType: TextInputType.text,
            onChanged: (_) => setState(() => _regionError = null),
          ),
        ],
      ),
      actions: [
        // ── Cancel
        DialogAction.secondary(
          label: 'Cancel',
          onPressed: state.isLoading ? null : _handleCancel,
        ),

        // ── Submit
        DialogAction.primary(
          label: 'Add Team',
          onPressed: _handleSubmit,
          isLoading: state.isLoading,
          isDisabled: !_hasValidInput || _hasAnyError,
        ),
      ],
    );
  }
}