// lib/ui/machine_detail_screen/widgets/start_batch_quantity_step.dart

import 'package:flutter/material.dart';

class StartBatchQuantityStep extends StatefulWidget {
  final String machineName;
  final int initialQuantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onProceed;

  const StartBatchQuantityStep({
    super.key,
    required this.machineName,
    required this.initialQuantity,
    required this.onQuantityChanged,
    required this.onProceed,
  });

  @override
  State<StartBatchQuantityStep> createState() => _StartBatchQuantityStepState();
}

class _StartBatchQuantityStepState extends State<StartBatchQuantityStep> {
  late int _quantity;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
    _controller = TextEditingController(text: _quantity.toString());
  }

  void _increment() {
    setState(() {
      _quantity++;
      _controller.text = _quantity.toString();
      widget.onQuantityChanged(_quantity);
    });
  }

  void _decrement() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
        _controller.text = _quantity.toString();
        widget.onQuantityChanged(_quantity);
      });
    }
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
        const Spacer(flex: 2),
        
        // Machine Name
        Text(
          widget.machineName,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        
        // Headline
        const Text(
          'Gaano Karami ang\niyong nilagay?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 48),
        
        // Quantity Selector
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                width: 100,
                alignment: Alignment.center,
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    final newVal = int.tryParse(value) ?? 0;
                    setState(() {
                      _quantity = newVal;
                    });
                    widget.onQuantityChanged(newVal);
                  },
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.normal,
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
        const SizedBox(height: 16),
        
        // Instruction
        const Text(
          'Type a number or use +/- buttons,',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black45,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const Spacer(flex: 3),
        
        // Proceed Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onProceed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD1DCE5),
              foregroundColor: Colors.black54,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.black12),
              ),
            ),
            child: const Text(
              'PROCEED',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
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
      elevation: 2,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.blueGrey, size: 32),
        ),
      ),
    );
  }
}
