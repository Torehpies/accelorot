// lib/ui/machine_detail_screen/view/start_batch_screen.dart

import 'package:flutter/material.dart';
import '../widgets/start_batch_quantity_step.dart';
import '../widgets/start_batch_substrate_step.dart';

class StartBatchScreen extends StatefulWidget {
  final String machineName;

  const StartBatchScreen({super.key, required this.machineName});

  @override
  State<StartBatchScreen> createState() => _StartBatchScreenState();
}

class _StartBatchScreenState extends State<StartBatchScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // State to hold values between steps
  int _quantity = 0;
  Set<String> _selectedSubstrates = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep = 1;
      });
    } else {
      // Final Step: Return result
      Navigator.of(context).pop(_quantity);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep = 0;
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
              StartBatchQuantityStep(
                machineName: widget.machineName,
                initialQuantity: _quantity,
                onQuantityChanged: (val) => _quantity = val,
                onProceed: _nextStep,
              ),
              
              // Step 2: Substrate
              StartBatchSubstrateStep(
                machineName: widget.machineName,
                selectedSubstrates: _selectedSubstrates,
                onSubstratesChanged: (val) => _selectedSubstrates = val,
                onProceed: _nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
