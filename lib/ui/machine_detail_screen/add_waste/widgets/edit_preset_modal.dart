import 'package:flutter/material.dart';
import '../model/substrate_preset.dart';

class EditSubstratePresetModal extends StatefulWidget {
  final SubstratePreset? preset; // null for "New Preset"
  final Function(SubstratePreset) onSave;

  const EditSubstratePresetModal({
    super.key,
    this.preset,
    required this.onSave,
  });

  @override
  State<EditSubstratePresetModal> createState() => _EditSubstratePresetModalState();
}

class _EditSubstratePresetModalState extends State<EditSubstratePresetModal> {
  late TextEditingController _nameController;
  final TextEditingController _customMaterialController = TextEditingController();
  late Set<SubstrateMaterial> _selectedMaterials;

  bool _isAddingGreen = false;
  bool _isAddingBrown = false;

  late List<SubstrateMaterial> _greenMaterials;
  late List<SubstrateMaterial> _brownMaterials;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.preset?.name ?? '');
    _selectedMaterials = widget.preset != null 
        ? Set.from(widget.preset!.materials) 
        : {};

    _greenMaterials = [
      const SubstrateMaterial(label: 'Vegetable Scraps', isNitrogenRich: true),
      const SubstrateMaterial(label: 'Fruit Scraps', isNitrogenRich: true),
      const SubstrateMaterial(label: 'Chicken Manure', isNitrogenRich: true),
      const SubstrateMaterial(label: 'Plant Stem', isNitrogenRich: true),
      const SubstrateMaterial(label: 'Grass Clippings', isNitrogenRich: true),
    ];

    _brownMaterials = [
      const SubstrateMaterial(label: 'Sawdust', isNitrogenRich: false),
      const SubstrateMaterial(label: 'Cardboard', isNitrogenRich: false),
      const SubstrateMaterial(label: 'Dry Grass', isNitrogenRich: false),
      const SubstrateMaterial(label: 'Coconut Husk', isNitrogenRich: false),
      const SubstrateMaterial(label: 'Dried Leaves', isNitrogenRich: false),
    ];
    
    // Ensure all materials in preset are in the list
    if (widget.preset != null) {
      for (var m in widget.preset!.materials) {
        if (m.isNitrogenRich) {
          if (!_greenMaterials.any((g) => g.label == m.label)) {
            _greenMaterials.add(m);
          }
        } else {
          if (!_brownMaterials.any((b) => b.label == m.label)) {
            _brownMaterials.add(m);
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customMaterialController.dispose();
    super.dispose();
  }

  void _addCustomMaterial(bool isNitrogen) {
    final label = _customMaterialController.text.trim();
    if (label.isEmpty) return;

    final newMaterial = SubstrateMaterial(label: label, isNitrogenRich: isNitrogen);
    
    setState(() {
      if (isNitrogen) {
        // If it's already in the other list, we might want to move it or just add here?
        // Let's just ensure it's in the Greens list.
        if (!_greenMaterials.any((m) => m.label == label)) {
          _greenMaterials.add(newMaterial);
        }
        _isAddingGreen = false;
      } else {
        if (!_brownMaterials.any((m) => m.label == label)) {
          _brownMaterials.add(newMaterial);
        }
        _isAddingBrown = false;
      }
      
      // Select it! If an equal material already existed in selection (even if category was different),
      // we remove the old one first to ensure the NEW one with correct category is the one in the set.
      _selectedMaterials.removeWhere((m) => m.label == label);
      _selectedMaterials.add(newMaterial);
      
      _customMaterialController.clear();
    });
  }

  void _toggleMaterial(SubstrateMaterial material) {
    setState(() {
      if (_selectedMaterials.contains(material)) {
        _selectedMaterials.remove(material);
      } else {
        _selectedMaterials.add(material);
      }
    });
  }

  void _onSave() {
    if (_nameController.text.trim().isEmpty) return;
    
    final newPreset = SubstratePreset(
      id: widget.preset?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      materials: _selectedMaterials.toList(),
      icon: widget.preset?.icon ?? 'usual_mix',
    );
    
    widget.onSave(newPreset);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    bool isNew = widget.preset == null;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 32,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isNew ? 'New Preset' : 'Edit Preset',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003D4C),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isNew ? 'Name it and pick the materials' : 'Editing "${widget.preset!.name}"',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSectionLabel('PRESET NAME'),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g. Usual Mix',
                filled: true,
                fillColor: const Color(0xFFF5F7F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFB0C4DE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFB0C4DE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF003D4C), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            
            _buildSectionLabel('GREENS (Nitrogen-Rich)'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._greenMaterials.map((m) => _buildChip(m)),
                if (!_isAddingGreen) _buildAddButton(true),
              ],
            ),
            if (_isAddingGreen) _buildAddInput(true),
            const SizedBox(height: 24),
            
            _buildSectionLabel('BROWNS (Carbon-Rich)'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._brownMaterials.map((m) => _buildChip(m)),
                if (!_isAddingBrown) _buildAddButton(false),
              ],
            ),
            if (_isAddingBrown) _buildAddInput(false),
            const SizedBox(height: 32),
            
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFEAF4FB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E2E3D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Preset', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFFB0C4DE),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildChip(SubstrateMaterial material) {
    bool isSelected = _selectedMaterials.contains(material);
    final baseColor = material.isNitrogenRich 
        ? const Color(0xFF439657) 
        : const Color(0xFFB0714E);
    
    return InkWell(
      onTap: () => _toggleMaterial(material),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : baseColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : baseColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          material.label,
          style: TextStyle(
            color: isSelected ? Colors.white : baseColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(bool isNitrogen) {
    final color = isNitrogen ? const Color(0xFF439657) : const Color(0xFFB0714E);
    return InkWell(
      onTap: () {
        setState(() {
          if (isNitrogen) {
            _isAddingGreen = true;
          } else {
            _isAddingBrown = true;
          }
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3), style: BorderStyle.solid, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              'Add',
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddInput(bool isNitrogen) {
    final color = isNitrogen ? const Color(0xFF439657) : const Color(0xFFB0714E);
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _customMaterialController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: isNitrogen ? 'e.g. Coffee Grounds' : 'e.g. Wood Chips',
                filled: true,
                fillColor: const Color(0xFFF5F7F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: color.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: color, width: 2),
                ),
              ),
              onSubmitted: (_) => _addCustomMaterial(isNitrogen),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _addCustomMaterial(isNitrogen),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
