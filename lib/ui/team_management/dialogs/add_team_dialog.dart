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
import 'package:flutter_application_1/ui/team_management/view_model/psgc_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import PSGC models
import 'package:flutter_application_1/data/models/psgc/psgc_region.dart';
import 'package:flutter_application_1/data/models/psgc/psgc_province.dart';
import 'package:flutter_application_1/data/models/psgc/psgc_city_municipality.dart';
import 'package:flutter_application_1/data/models/psgc/psgc_barangay.dart';

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

  // ── Per-field error state
  String? _teamNameError;
  String? _houseNumberError;
  String? _streetError;
  String? _regionError;
  String? _provinceError;
  String? _cityError;
  String? _barangayError;

  @override
  void initState() {
    super.initState();
    // Load regions when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(psgcProvider.notifier).loadRegions();
    });
  }

  // ── Derived helpers
  bool get _isDirty {
     final psgcState = ref.read(psgcProvider);
     return _teamNameController.text.isNotEmpty ||
      _houseNumberController.text.isNotEmpty ||
      _streetController.text.isNotEmpty ||
      psgcState.selectedRegion != null;
  }

  bool _validate() {
    final teamName = _teamNameController.text.trim();
    final houseNumber = _houseNumberController.text.trim();
    final street = _streetController.text.trim();
    
    final psgcState = ref.read(psgcProvider);

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

      _regionError = psgcState.selectedRegion == null ? 'Region is required' : null;
      
      // Province is required only if the region has provinces
      if (psgcState.regions.isNotEmpty && psgcState.selectedRegion != null) {
          _provinceError = (psgcState.provinces.isNotEmpty && psgcState.selectedProvince == null) 
              ? 'Province is required' 
              : null;
      } else {
        _provinceError = null;
      }

      _cityError = psgcState.selectedCityMunicipality == null ? 'City/Municipality is required' : null;
      _barangayError = psgcState.selectedBarangay == null ? 'Barangay is required' : null;
    });

    return _teamNameError == null &&
        _houseNumberError == null &&
        _streetError == null &&
        _regionError == null &&
        _provinceError == null &&
        _cityError == null &&
        _barangayError == null;
  }

  bool get _hasValidInput {
      final psgcState = ref.read(psgcProvider);
      final hasProvinceIfRequired = psgcState.provinces.isEmpty || psgcState.selectedProvince != null;

      return _teamNameController.text.isNotEmpty &&
             _houseNumberController.text.isNotEmpty &&
             _streetController.text.isNotEmpty &&
             psgcState.selectedRegion != null &&
             hasProvinceIfRequired &&
             psgcState.selectedCityMunicipality != null &&
             psgcState.selectedBarangay != null;
  }
  
  bool get _hasAnyError =>
      _teamNameError != null ||
      _houseNumberError != null ||
      _streetError != null ||
      _regionError != null ||
      _provinceError != null ||
      _cityError != null ||
      _barangayError != null;


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
      if (result == ConfirmResult.confirmed) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
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

  // ── Business logic
  void _addTeam() {
    final teamName = _teamNameController.text.trim();
    final houseNumber = _houseNumberController.text.trim();
    final street = _streetController.text.trim();
    
    final psgcState = ref.read(psgcProvider);
    
    final region = psgcState.selectedRegion?.name ?? '';
    final province = psgcState.selectedProvince?.name ?? ''; // Optional
    final city = psgcState.selectedCityMunicipality?.name ?? '';
    final barangay = 'BRGY. ${psgcState.selectedBarangay?.name ?? ''}';

    // Construct full address
    final addressParts = [
      houseNumber,
      street,
      barangay,
      city,
      if (province.isNotEmpty) province,
      region,
    ];
    
    final address = addressParts.where((s) => s.isNotEmpty).join(', ');

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
    super.dispose();
  }

  // ── Build
  @override
  Widget build(BuildContext context) {
    final addTeamState = ref.watch(addTeamProvider);
    final psgcState = ref.watch(psgcProvider);
    final psgcNotifier = ref.read(psgcProvider.notifier);

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
      canClose: !addTeamState.isLoading,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Team Name
          InputField(
            label: 'Team Name',
            controller: _teamNameController,
            hintText: 'Team',
            errorText: _teamNameError,
            enabled: !addTeamState.isLoading,
            required: true,
            keyboardType: TextInputType.text,
            onChanged: (_) => setState(() => _teamNameError = null),
          ),
          const SizedBox(height: 16),

          // ── House / Lot / Block
          InputField(
            label: 'House/Lot/Block',
            controller: _houseNumberController,
            hintText: '1111 / Lot 10 Blk 10',
            errorText: _houseNumberError,
            enabled: !addTeamState.isLoading,
            required: true,
            keyboardType: TextInputType.streetAddress,
            onChanged: (_) => setState(() => _houseNumberError = null),
          ),
          const SizedBox(height: 16),

          // ── Street / Road / Subd.
          InputField(
            label: 'Street/Road/Subd.',
            controller: _streetController,
            hintText: 'Libra St. / Zabarte Road / Luisa Subd.',
            errorText: _streetError,
            enabled: !addTeamState.isLoading,
            required: true,
            keyboardType: TextInputType.streetAddress,
            onChanged: (_) => setState(() => _streetError = null),
          ),
          const SizedBox(height: 16),
          
          if (psgcState.isLoading && psgcState.regions.isEmpty)
             const Padding(
               padding: EdgeInsets.all(8.0),
               child: Center(child: LinearProgressIndicator()),
             ),
             
          // ── Region
          WebDropdownField<PsgcRegion>(
            label: 'Region',
            value: psgcState.selectedRegion,
            items: psgcState.regions.map((r) => DropdownItem(value: r, label: r.name)).toList(),
            hintText: 'Select Region',
            errorText: _regionError,
            enabled: !addTeamState.isLoading && !psgcState.isLoading,
            required: true,
            onChanged: (region) {
               setState(() {
                 _regionError = null;
                 _provinceError = null;
                 _cityError = null;
                 _barangayError = null;
               });
               psgcNotifier.selectRegion(region);
            },
          ),
          const SizedBox(height: 16),

          // ── Province (Only if available)
          if (psgcState.provinces.isNotEmpty) ...[
            WebDropdownField<PsgcProvince>(
              label: 'Province',
              value: psgcState.selectedProvince,
              items: psgcState.provinces.map((p) => DropdownItem(value: p, label: p.name)).toList(),
              hintText: 'Select Province',
              errorText: _provinceError,
              enabled: !addTeamState.isLoading && !psgcState.isLoading,
              required: true,
              onChanged: (province) {
                setState(() {
                  _provinceError = null;
                  _cityError = null;
                  _barangayError = null;
                });
                psgcNotifier.selectProvince(province);
              },
            ),
            const SizedBox(height: 16),
          ],

          // ── City / Municipality
          WebDropdownField<PsgcCityMunicipality>(
            label: 'City / Municipality',
            value: psgcState.selectedCityMunicipality,
            items: psgcState.citiesMunicipalities.map((c) => DropdownItem(value: c, label: c.name)).toList(),
            hintText: 'Select City/Municipality',
            errorText: _cityError,
            enabled: !addTeamState.isLoading && !psgcState.isLoading && (psgcState.selectedRegion != null),
            required: true,
            onChanged: (city) {
              setState(() {
                _cityError = null;
                _barangayError = null;
              });
              psgcNotifier.selectCityMunicipality(city);
            },
          ),
          const SizedBox(height: 16),

          // ── Barangay
          WebDropdownField<PsgcBarangay>(
            label: 'Barangay',
            value: psgcState.selectedBarangay,
            items: psgcState.barangays.map((b) => DropdownItem(value: b, label: b.name)).toList(),
            hintText: 'Select Barangay',
            errorText: _barangayError,
            enabled: !addTeamState.isLoading && !psgcState.isLoading && (psgcState.selectedCityMunicipality != null),
            required: true,
            onChanged: (barangay) {
              setState(() => _barangayError = null);
              psgcNotifier.selectBarangay(barangay);
            },
          ),
        ],
      ),
      actions: [
        // ── Cancel
        DialogAction.secondary(
          label: 'Cancel',
          onPressed: addTeamState.isLoading ? null : _handleCancel,
        ),

        // ── Submit
        DialogAction.primary(
          label: 'Add Team',
          onPressed: _handleSubmit,
          isLoading: addTeamState.isLoading,
          isDisabled: !_hasValidInput || _hasAnyError,
        ),
      ],
    );
  }
}	
