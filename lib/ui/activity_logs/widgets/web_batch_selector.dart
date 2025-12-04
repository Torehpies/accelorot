// lib/ui/activity_logs/widgets/web_batch_selector.dart

import 'package:flutter/material.dart';

/// Batch selector component for filtering activities by batch
/// Currently pure UI - no filtering logic implemented
class WebBatchSelector extends StatefulWidget {
  const WebBatchSelector({super.key});

  @override
  State<WebBatchSelector> createState() => _WebBatchSelectorState();
}

class _WebBatchSelectorState extends State<WebBatchSelector> {
  String? _selectedBatch;
  final List<String> _batchOptions = ['Batch 1', 'Batch 2', 'Batch 3'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title Text
          Row(
            children: [
              Icon(Icons.inventory_2, color: Colors.teal.shade700, size: 20),
              const SizedBox(width: 12),
              Text(
                'Select A Batch',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
            ],
          ),
          
          // Dropdown Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<String>(
              value: _selectedBatch,
              hint: const Text(
                'All Batches',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.teal,
                fontSize: 14,
              ),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(8),
              items: _batchOptions.map((String batch) {
                return DropdownMenuItem<String>(
                  value: batch,
                  child: Text(
                    batch,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBatch = newValue;
                });
                // TODO: Implement batch filtering logic when needed
              },
            ),
          ),
        ],
      ),
    );
  }
}