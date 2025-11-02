// lib/frontend/operator/activity_logs/components/batch_filter_section.dart
import 'package:flutter/material.dart';

class BatchFilterSection extends StatefulWidget {
  const BatchFilterSection({super.key});

  @override
  State<BatchFilterSection> createState() => _BatchFilterSectionState();
}

class _BatchFilterSectionState extends State<BatchFilterSection> {
  String? _selectedBatch;
  final List<String> _batchOptions = ['Batch 1', 'Batch 2', 'Batch 3'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2), 
            offset: const Offset(0, 4), 
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Title Text
          Text(
            'Select A Batch',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),

          // 2. Dropdown Filter
          DropdownButton<String>(
            value: _selectedBatch,
            
            // --- Style for the button itself (The part that shows the value) ---
            hint: const Text(
              'All Batches',
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            // Style for the selected value
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.teal, 
              fontSize: 16,
            ),
            
            underline: const SizedBox(), 
            icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),

            // --- Style for the dropdown menu ---
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            alignment: AlignmentDirectional.centerStart,

            // --- Menu Items ---
            items: _batchOptions.map((String batch) {
              return DropdownMenuItem<String>(
                value: batch,
                child: Text(
                  batch,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
            
            // --- Logic ---
            onChanged: (String? newValue) {
              setState(() {
                _selectedBatch = newValue;
              });
            },
          ),
        ],
      ),
    );
  }
}