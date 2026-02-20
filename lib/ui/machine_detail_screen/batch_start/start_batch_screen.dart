// lib/ui/machine_detail_screen/view/start_batch_screen.dart

import 'package:flutter/material.dart';

class StartBatchScreen extends StatefulWidget {
  final String machineName;

  const StartBatchScreen({super.key, required this.machineName});

  @override
  State<StartBatchScreen> createState() => _StartBatchScreenState();
}

class _StartBatchScreenState extends State<StartBatchScreen> {
  int _quantity = 0;
  final TextEditingController _controller = TextEditingController(text: '0');

  void _increment() {
    setState(() {
      _quantity++;
      _controller.text = _quantity.toString();
    });
  }

  void _decrement() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
        _controller.text = _quantity.toString();
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
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
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
                          setState(() {
                            _quantity = int.tryParse(value) ?? 0;
                          });
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
                  onPressed: () => Navigator.of(context).pop(_quantity),
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
          ),
        ),
      ),
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
