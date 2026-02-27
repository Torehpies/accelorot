import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/substrate_preset.dart';
import '../../../../data/providers/substrate_providers.dart';
import 'substrate_preset_card.dart';

class AddWastePresetStep extends ConsumerStatefulWidget {
  final String machineName;
  final Set<String> selectedSubstrates;
  final ValueChanged<Set<String>> onSubstratesChanged;
  final VoidCallback onProceed;
  final VoidCallback onAddNewPreset;
  final Function(SubstratePreset) onEditPreset;

  const AddWastePresetStep({
    super.key,
    required this.machineName,
    required this.selectedSubstrates,
    required this.onSubstratesChanged,
    required this.onProceed,
    required this.onAddNewPreset,
    required this.onEditPreset,
  });

  @override
  ConsumerState<AddWastePresetStep> createState() => _AddWastePresetStepState();
}

class _AddWastePresetStepState extends ConsumerState<AddWastePresetStep> {
  String? _selectedPresetId;

  void _onPresetTap(SubstratePreset preset) {
    setState(() {
      _selectedPresetId = preset.id;
      final substrateLabels = preset.materials.map((m) => m.label).toSet();
      widget.onSubstratesChanged(substrateLabels);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          'Ano ang iyong mga\nnilagay?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 32),
        
        // Presets List
        Expanded(
          child: ref.watch(teamPresetsProvider).when(
            data: (presets) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    ...presets.map((preset) => SubstratePresetCard(
                      preset: preset,
                      isSelected: _selectedPresetId == preset.id,
                      onTap: () => _onPresetTap(preset),
                      onEdit: () => widget.onEditPreset(preset),
                      onDelete: () async {
                        try {
                          await ref.read(substrateRepositoryProvider).deletePreset(preset.id);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete preset: $e')),
                            );
                          }
                        }
                      },
                    )),
                    
                    const SizedBox(height: 8),
                    
                    // Add new preset button
                    TextButton.icon(
                      onPressed: widget.onAddNewPreset,
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(
                        'Save a new preset',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF5C9BAD),
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Proceed Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.selectedSubstrates.isNotEmpty ? widget.onProceed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.selectedSubstrates.isNotEmpty 
                  ? const Color(0xFF003D4C) 
                  : const Color(0xFFE5EBEF),
              foregroundColor: widget.selectedSubstrates.isNotEmpty ? Colors.white : Colors.black26,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
}
