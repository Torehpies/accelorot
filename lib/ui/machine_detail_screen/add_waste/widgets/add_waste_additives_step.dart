// lib/ui/machine_detail_screen/batch_start/widgets/start_batch_additives_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/substrate_providers.dart';

class AdditiveOption {
  final String label;
  final Color color;
  final Color textColor;

  const AdditiveOption({
    required this.label,
    required this.color,
    required this.textColor,
  });
}

class AddWasteAdditivesStep extends ConsumerStatefulWidget {
  final String machineName;
  final Set<String> selectedAdditives;
  final ValueChanged<Set<String>> onAdditivesChanged;
  final VoidCallback onProceed;

  const AddWasteAdditivesStep({
    super.key,
    required this.machineName,
    required this.selectedAdditives,
    required this.onAdditivesChanged,
    required this.onProceed,
  });

  @override
  ConsumerState<AddWasteAdditivesStep> createState() => _AddWasteAdditivesStepState();
}

class _AddWasteAdditivesStepState extends ConsumerState<AddWasteAdditivesStep> {
  bool? _hasAdditives;
  late Set<String> _selected;
  late List<AdditiveOption> _options;
  
  bool _isAddingCustom = false;
  final TextEditingController _addController = TextEditingController();

  // Purple theme for additives based on WebColors.reportsIcon/airQuality
  final Color _purpleBg = const Color(0xFFF5EEFF);
  final Color _purpleText = const Color(0xFF8B5CF6);
  final Color _purpleSelected = const Color(0xFF8B5CF6);

  final List<AdditiveOption> _initialOptions = [
    const AdditiveOption(label: 'EM1', color: Color(0xFFF5EEFF), textColor: Color(0xFF8B5CF6)),
    const AdditiveOption(label: 'Molasses', color: Color(0xFFF5EEFF), textColor: Color(0xFF8B5CF6)),
    const AdditiveOption(label: 'Bokashi', color: Color(0xFFF5EEFF), textColor: Color(0xFF8B5CF6)),
    const AdditiveOption(label: 'Compost Starter', color: Color(0xFFF5EEFF), textColor: Color(0xFF8B5CF6)),
    const AdditiveOption(label: 'Garden Soil', color: Color(0xFFF5EEFF), textColor: Color(0xFF8B5CF6)),
    const AdditiveOption(label: 'Seaweed Extract', color: Color(0xFFF5EEFF), textColor: Color(0xFF8B5CF6)),
  ];

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.selectedAdditives);
    if (_selected.isNotEmpty) {
      _hasAdditives = true;
    }
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
      widget.onAdditivesChanged(_selected);
    });
  }

  void _addCustomAdditive() async {
    final label = _addController.text.trim();
    if (label.isEmpty) return;

    try {
      await ref.read(substrateRepositoryProvider).saveCustomAdditive(label);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving additive: $e')));
      }
    }

    if (mounted) {
      setState(() {
        _selected.add(label);
        widget.onAdditivesChanged(_selected);
        
        _isAddingCustom = false;
        _addController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        
        // Machine Name & Date
        Text(
          '${widget.machineName}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black38,
          ),
        ),
        const SizedBox(height: 4),
        
        // Headline
        const Text(
          'Naglagay ka ba ng\nadditives?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A5F),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 24),
        
        // Toggle Buttons (Fixed overflow with Expanded)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _buildToggleButton(
                label: 'Oo, naglagay',
                isSelected: _hasAdditives == true,
                icon: Icons.check,
                selectedColor: const Color(0xFF439657), // Compact green
                onTap: () => setState(() {
                  _hasAdditives = true;
                  _isAddingCustom = false;
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToggleButton(
                label: 'Wala',
                isSelected: _hasAdditives == false,
                icon: Icons.close,
                selectedColor: const Color(0xFF547589),
                onTap: () => setState(() {
                  _hasAdditives = false;
                  _selected.clear();
                  widget.onAdditivesChanged(_selected);
                }),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Content area
        Expanded(
          child: SingleChildScrollView(
            child: _buildConditionalContent(),
          ),
        ),

        const SizedBox(height: 24),
        
        // Proceed Button
        _buildProceedButton(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required IconData icon,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [
            BoxShadow(
              color: selectedColor.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : selectedColor.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : selectedColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionalContent() {
    if (_hasAdditives == true) {
      final customAdditives = ref.watch(teamCustomAdditivesProvider).asData?.value ?? [];
      final allAdditives = List<AdditiveOption>.from(_initialOptions);
      
      for (final customLabel in customAdditives) {
        if (!allAdditives.any((opt) => opt.label == customLabel)) {
          allAdditives.add(AdditiveOption(
            label: customLabel,
            color: _purpleBg,
            textColor: _purpleText,
          ));
        }
      }
      
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Piliin ang iyong mga additives',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: _purpleText.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.start,
            children: [
              ...allAdditives.map((option) {
                final isSelected = _selected.contains(option.label);
                return _AdditiveChip(
                  label: option.label,
                  isSelected: isSelected,
                  selectedColor: _purpleSelected,
                  unselectedColor: option.color,
                  textColor: option.textColor,
                  onTap: () => _toggleOption(option.label),
                );
              }),
              if (!_isAddingCustom)
                _buildAddButtonStyle(),
            ],
          ),
          if (_isAddingCustom) ...[
            const SizedBox(height: 12),
            _buildAddInput(),
          ],
        ],
      );
    } else if (_hasAdditives == false) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Text(
              '👍',
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 12),
            Text(
              'Walang additives — noted!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF547589).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildAddButtonStyle() {
    return InkWell(
      onTap: () => setState(() => _isAddingCustom = true),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: _purpleText.withValues(alpha: 0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: _purpleText.withValues(alpha: 0.6)),
            const SizedBox(width: 4),
            Text(
              'Add',
              style: TextStyle(
                color: _purpleText.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _addController,
            autofocus: true,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'e.g. Yeast',
              hintStyle: TextStyle(color: _purpleText.withValues(alpha: 0.4), fontSize: 13),
              filled: true,
              fillColor: _purpleBg.withValues(alpha: 0.5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: _purpleText.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: _purpleText.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: _purpleText.withValues(alpha: 0.4)),
              ),
            ),
            onSubmitted: (_) => _addCustomAdditive(),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _addCustomAdditive,
          style: ElevatedButton.styleFrom(
            backgroundColor: _purpleText,
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
    );
  }

  Widget _buildProceedButton() {
    // Styling proceed button based on state
    final bool isSelected = _hasAdditives != null;
    final Color bgColor = isSelected 
        ? const Color(0xFFD1DCE5)
        : const Color(0xFFE5EBEF);
    final Color textColor = isSelected 
        ? Colors.black54
        : Colors.black26;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isSelected ? widget.onProceed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
          disabledForegroundColor: textColor.withValues(alpha: 0.5),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isSelected ? Colors.black12 : Colors.transparent),
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
    );
  }
}

class _AdditiveChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final Color textColor;
  final VoidCallback onTap;

  const _AdditiveChip({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isSelected ? selectedColor : unselectedColor;
    final Color effectiveTextColor = isSelected ? Colors.white : textColor;

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
            color: isSelected ? Colors.transparent : textColor.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: selectedColor.withValues(alpha: 0.2),
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
              label,
              style: TextStyle(
                color: effectiveTextColor,
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
