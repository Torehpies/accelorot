// lib/ui/machine_detail_screen/widgets/start_batch_substrate_step.dart

import 'package:flutter/material.dart';

class SubstrateOption {
  final String label;
  final Color color;
  final Color textColor;
  final bool isNitrogenRich;

  const SubstrateOption({
    required this.label,
    required this.color,
    required this.textColor,
    required this.isNitrogenRich,
  });
}

class AddWasteSubstrateStep extends StatefulWidget {
  final String machineName;
  final Set<String> selectedSubstrates;
  final ValueChanged<Set<String>> onSubstratesChanged;
  final VoidCallback onProceed;

  const AddWasteSubstrateStep({
    super.key,
    required this.machineName,
    required this.selectedSubstrates,
    required this.onSubstratesChanged,
    required this.onProceed,
  });

  @override
  State<AddWasteSubstrateStep> createState() => _AddWasteSubstrateStepState();
}

class _AddWasteSubstrateStepState extends State<AddWasteSubstrateStep> {
  late Set<String> _selected;
  late List<SubstrateOption> _options;
  
  bool _isAddingNitrogen = false;
  bool _isAddingCarbon = false;
  final TextEditingController _addController = TextEditingController();

  final List<SubstrateOption> _initialOptions = [
    const SubstrateOption(
      label: 'Vegetable Scraps',
      color: Color(0xFFE8F5E9), // Light Green
      textColor: Color(0xFF4CAF50),
      isNitrogenRich: true,
    ),
    const SubstrateOption(
      label: 'Fruit Scraps',
      color: Color(0xFFE8F5E9), // Light Green
      textColor: Color(0xFF4CAF50),
      isNitrogenRich: true,
    ),
    const SubstrateOption(
      label: 'Chicken Manure',
      color: Color(0xFFE8F5E9), // Light Green
      textColor: Color(0xFF4CAF50),
      isNitrogenRich: true,
    ),
    const SubstrateOption(
      label: 'Plant Stem',
      color: Color(0xFFE8F5E9), // Light Green
      textColor: Color(0xFF4CAF50),
      isNitrogenRich: true,
    ),
    const SubstrateOption(
      label: 'Sawdust',
      color: Color(0xFFF9F1E7), // Light Brown
      textColor: Color(0xFF8D6E63),
      isNitrogenRich: false,
    ),
    const SubstrateOption(
      label: 'Cardboard',
      color: Color(0xFFF9F1E7), // Light Brown
      textColor: Color(0xFF8D6E63),
      isNitrogenRich: false,
    ),
    const SubstrateOption(
      label: 'Dry Grass',
      color: Color(0xFFF9F1E7), // Light Brown
      textColor: Color(0xFF8D6E63),
      isNitrogenRich: false,
    ),
    const SubstrateOption(
      label: 'Coconut Husk',
      color: Color(0xFFF9F1E7), // Light Brown
      textColor: Color(0xFF8D6E63),
      isNitrogenRich: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedSubstrates);
    _options = List.from(_initialOptions);
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _toggleOption(String label) {
    setState(() {
      if (_selected.contains(label)) {
        _selected.remove(label);
      } else {
        _selected.add(label);
      }
      widget.onSubstratesChanged(_selected);
    });
  }

  void _addCustomSubstrate(bool isNitrogen) {
    final label = _addController.text.trim();
    if (label.isEmpty) return;

    setState(() {
      final newOption = SubstrateOption(
        label: label,
        color: isNitrogen ? const Color(0xFFE8F5E9) : const Color(0xFFF9F1E7),
        textColor: isNitrogen ? const Color(0xFF4CAF50) : const Color(0xFF8D6E63),
        isNitrogenRich: isNitrogen,
      );
      
      _options.add(newOption);
      _selected.add(label);
      widget.onSubstratesChanged(_selected);
      
      // Reset state
      _isAddingNitrogen = false;
      _isAddingCarbon = false;
      _addController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nitrogenOptions = _options.where((o) => o.isNitrogenRich).toList();
    final carbonOptions = _options.where((o) => !o.isNitrogenRich).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        
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
          'What did you\nadd?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 32),
        
        // Substrate Grid/Wrap
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildCategoryHeader(
                  label: 'NITROGEN-RICH MATERIALS',
                  dotColor: const Color(0xFF4CAF50),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ...nitrogenOptions.map((option) {
                      final isSelected = _selected.contains(option.label);
                      return _SubstrateChip(
                        option: option,
                        isSelected: isSelected,
                        onTap: () => _toggleOption(option.label),
                      );
                    }),
                    if (!_isAddingNitrogen)
                      _buildAddChip(
                        const Color(0xFFE8F5E9),
                        const Color(0xFF4CAF50),
                        () => setState(() {
                          _isAddingNitrogen = true;
                          _isAddingCarbon = false;
                          _addController.clear();
                        }),
                      ),
                  ],
                ),
                if (_isAddingNitrogen) ...[
                  const SizedBox(height: 10),
                  _buildAddInput(true),
                ],
                const SizedBox(height: 24),
                _buildCategoryHeader(
                  label: 'CARBON-RICH MATERIALS',
                  dotColor: const Color(0xFF8D6E63),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ...carbonOptions.map((option) {
                      final isSelected = _selected.contains(option.label);
                      return _SubstrateChip(
                        option: option,
                        isSelected: isSelected,
                        onTap: () => _toggleOption(option.label),
                      );
                    }),
                    if (!_isAddingCarbon)
                      _buildAddChip(
                        const Color(0xFFF9F1E7),
                        const Color(0xFF8D6E63),
                        () => setState(() {
                          _isAddingCarbon = true;
                          _isAddingNitrogen = false;
                          _addController.clear();
                        }),
                      ),
                  ],
                ),
                if (_isAddingCarbon) ...[
                  const SizedBox(height: 10),
                  _buildAddInput(false),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Proceed Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selected.isNotEmpty ? widget.onProceed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selected.isNotEmpty ? const Color(0xFFD1DCE5) : const Color(0xFFE5EBEF),
              foregroundColor: _selected.isNotEmpty ? Colors.black54 : Colors.black26,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: _selected.isNotEmpty ? Colors.black12 : Colors.transparent),
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

  Widget _buildCategoryHeader({required String label, required Color dotColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: dotColor.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildAddInput(bool isNitrogen) {
    final color = isNitrogen ? const Color(0xFF4CAF50) : const Color(0xFF8D6E63);
    final bgColor = isNitrogen ? const Color(0xFFEAF5EF) : const Color(0xFFF9F4F2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _addController,
              autofocus: true,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: isNitrogen ? 'e.g. Grass Clippings' : 'e.g. Dried Leaves',
                hintStyle: TextStyle(color: color.withValues(alpha: 0.5), fontSize: 13),
                filled: true,
                fillColor: bgColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: color.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: color.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: color.withValues(alpha: 0.5)),
                ),
              ),
              onSubmitted: (_) => _addCustomSubstrate(isNitrogen),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _addCustomSubstrate(isNitrogen),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddChip(Color bgColor, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: textColor.withValues(alpha: 0.2),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: textColor.withValues(alpha: 0.8)),
            const SizedBox(width: 4),
            Text(
              'Add',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubstrateChip extends StatelessWidget {
  final SubstrateOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubstrateChip({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Colors based on image: Green for Nitrogen, Brown for Carbon
    final Color selectedBg = option.isNitrogenRich 
        ? const Color(0xFF439657) 
        : const Color(0xFFB0714E);
    
    final Color bgColor = isSelected ? selectedBg : option.color;
    final Color textColor = isSelected ? Colors.white : option.textColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.transparent : option.textColor.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: selectedBg.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, size: 14, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              option.label,
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
