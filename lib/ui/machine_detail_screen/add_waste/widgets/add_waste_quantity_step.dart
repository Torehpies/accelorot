// lib/ui/machine_detail_screen/widgets/start_batch_quantity_step.dart

import 'package:flutter/material.dart';

class AddWasteQuantityStep extends StatefulWidget {
  final String machineName;
  final int initialQuantity;
  final double currentWaste;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onProceed;

  const AddWasteQuantityStep({
    super.key,
    required this.machineName,
    required this.initialQuantity,
    required this.currentWaste,
    required this.onQuantityChanged,
    required this.onProceed,
  });

  @override
  State<AddWasteQuantityStep> createState() => _AddWasteQuantityStepState();
}

class _AddWasteQuantityStepState extends State<AddWasteQuantityStep> {
  late int _quantity;
  late TextEditingController _controller;
  
  late int _minAllowed;
  late int _maxAllowed;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
    _controller = TextEditingController(text: _quantity.toString());
    
    if (widget.currentWaste == 0) {
      _minAllowed = 60;
      _maxAllowed = 80;
    } else {
      _minAllowed = 1;
      _maxAllowed = (80 - widget.currentWaste).floor();
      if (_maxAllowed < 1) _maxAllowed = 1; // Fallback just in case
    }
  }

  void _increment() {
    setState(() {
      _errorMessage = null;
      if (_quantity < _maxAllowed) {
        _quantity++;
        _controller.text = _quantity.toString();
        widget.onQuantityChanged(_quantity);
      }
    });
  }

  void _decrement() {
    setState(() {
      _errorMessage = null;
      if (_quantity > _minAllowed) {
        _quantity--;
        _controller.text = _quantity.toString();
        widget.onQuantityChanged(_quantity);
      }
    });
  }

  void _handleProceed() {
    if (_quantity < _minAllowed) {
      setState(() {
        _errorMessage = 'Minimum required is $_minAllowed kg';
      });
      return;
    }
    if (_quantity > _maxAllowed) {
      setState(() {
        _errorMessage = 'Maximum allowed is $_maxAllowed kg';
      });
      return;
    }
    setState(() {
      _errorMessage = null;
    });
    widget.onProceed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(flex: 1),
        
        // Machine Name
        Text(
          widget.machineName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        
        // Headline
        const Text(
          'Gaano Karami ang\niyong nilagay?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        
        // Limits Subtitle
        Text(
          widget.currentWaste == 0 
            ? 'First fill requires $_minAllowed - $_maxAllowed kg'
            : 'You can add up to $_maxAllowed kg more',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6366f1),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        
        // Quantity Selector
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _errorMessage != null ? Colors.red : Colors.black12,
              width: _errorMessage != null ? 2 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Minus Button
              _buildActionButton(
                icon: Icons.remove,
                onPressed: _decrement,
              ),
              
              // Value
              Container(
                width: 80,
                alignment: Alignment.center,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    setState(() {
                      _errorMessage = null; // Clear error on edit
                    });
                    final newVal = int.tryParse(value) ?? 0;
                    setState(() {
                      _quantity = newVal;
                    });
                    widget.onQuantityChanged(newVal);
                  },
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              
              // Plus Button
              _buildActionButton(
                icon: Icons.add,
                onPressed: _increment,
              ),
            ],
          ),
        ),
        
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ] else ...[
          const SizedBox(height: 12),
          // Instruction
          const Text(
            'Type a number or use +/- buttons',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black45,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        
        const Spacer(flex: 2),
        
        // Proceed Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleProceed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD1DCE5),
              foregroundColor: Colors.black54,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.black12),
              ),
            ),
            child: const Text(
              'PROCEED',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.blueGrey, size: 24),
        ),
      ),
    );
  }
}
