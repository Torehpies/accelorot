import 'package:flutter/material.dart';
import '../widgets/add_waste_quantity_step.dart';
import '../widgets/add_waste_substrate_step.dart';
import '../widgets/add_waste_additives_step.dart';
import '../widgets/add_waste_final_step.dart';

class AddWasteScreen extends StatefulWidget {
  final String machineName;

  const AddWasteScreen({super.key, required this.machineName});

  @override
  State<AddWasteScreen> createState() => _AddWasteScreenState();
}

class _AddWasteScreenState extends State<AddWasteScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // State to hold values between steps
  int _quantity = 0;
  Set<String> _selectedSubstrates = {};
  Set<String> _selectedAdditives = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
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
              // Step 1: Quantity
              AddWasteQuantityStep(
                machineName: widget.machineName,
                initialQuantity: _quantity,
                onQuantityChanged: (val) => _quantity = val,
                onProceed: _nextStep,
              ),
              
              // Step 2: Substrate
              AddWasteSubstrateStep(
                machineName: widget.machineName,
                selectedSubstrates: _selectedSubstrates,
                onSubstratesChanged: (val) => _selectedSubstrates = val,
                onProceed: _nextStep,
              ),

              // Step 3: Additives
              AddWasteAdditivesStep(
                machineName: widget.machineName,
                selectedAdditives: _selectedAdditives,
                onAdditivesChanged: (val) => _selectedAdditives = val,
                onProceed: _nextStep,
              ),

              // Step 4: Final Confirmation
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
