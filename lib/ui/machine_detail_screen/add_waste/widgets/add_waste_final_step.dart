// lib/ui/machine_detail_screen/batch_start/widgets/start_batch_final_step.dart

import 'package:flutter/material.dart';

class AddWasteFinalStep extends StatelessWidget {
  final String machineName;
  final VoidCallback onStart;

  const AddWasteFinalStep({
    super.key,
    required this.machineName,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(flex: 1),
        
        // Machine Name
        Text(
          machineName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black38,
          ),
        ),
        const SizedBox(height: 4),
        
        // Ready!
        const Text(
          'Ready!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF547589),
          ),
        ),
        const SizedBox(height: 8),
        
        // Headline
        const Text(
          'Lock the drum door\nand tap start',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A5F),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 40),
        
        // Lock Icon Visual
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFD1DCE5).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.lock_outline,
              size: 80,
              color: Color(0xFF1E3A5F),
            ),
          ),
        ),
        
        const Spacer(flex: 2),
        
        // Start Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD1DCE5),
              foregroundColor: Colors.black54,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.black12, width: 1),
              ),
            ),
            child: const Text(
              'START',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
