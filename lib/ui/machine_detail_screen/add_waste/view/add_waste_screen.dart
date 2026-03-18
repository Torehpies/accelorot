import 'package:flutter/material.dart';
import '../widgets/add_waste_preset_step.dart';
import '../widgets/add_waste_additives_step.dart';
import '../widgets/add_waste_final_step.dart';
import '../widgets/edit_preset_modal.dart';
import '../../../../data/models/substrate_preset.dart';

class AddWasteScreen extends StatefulWidget {
  final String machineName;
  final double currentWaste;

  const AddWasteScreen({
    super.key, 
    required this.machineName,
    required this.currentWaste,
  });

  @override
  State<AddWasteScreen> createState() => _AddWasteScreenState();
}

class _AddWasteScreenState extends State<AddWasteScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // State to hold values between steps
  late int _quantity;
  Set<String> _selectedSubstrates = {};
  Set<String> _selectedAdditives = {};

  @override
  void initState() {
    super.initState();
    _quantity = widget.currentWaste == 0 ? 60 : 1;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }

  void _finish() {
    // Final Step: Return all results
    Navigator.of(context).pop({
      'quantity': _quantity,
      'substrates': _selectedSubstrates,
      'additives': _selectedAdditives,
    });
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showEditPresetModal([SubstratePreset? preset]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditSubstratePresetModal(
        preset: preset,
        onSave: (newPreset) {
          // In a real app, this would persist the preset.
          // For now, we'll just update the selection if it's the one we're editing.
          if (preset != null &&
              _selectedSubstrates
                  .containsAll(preset.materials.map((m) => m.label))) {
            setState(() {
              _selectedSubstrates =
                  newPreset.materials.map((m) => m.label).toSet();
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: _previousStep,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Step 1: Substrate Preset Picker
              AddWastePresetStep(
                machineName: widget.machineName,
                selectedSubstrates: _selectedSubstrates,
                onSubstratesChanged: (val) =>
                    setState(() => _selectedSubstrates = val),
                onProceed: _nextStep,
                onAddNewPreset: _showEditPresetModal,
                onEditPreset: _showEditPresetModal,
              ),

              // Step 2: Additives
              AddWasteAdditivesStep(
                machineName: widget.machineName,
                selectedAdditives: _selectedAdditives,
                onAdditivesChanged: (val) => _selectedAdditives = val,
                onProceed: _nextStep,
              ),

              // Step 3: Final Confirmation
              AddWasteFinalStep(
                machineName: widget.machineName,
                onStart: _finish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
