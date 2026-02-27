import 'package:flutter/material.dart';
import '../model/substrate_preset.dart';

class SubstratePresetCard extends StatelessWidget {
  final SubstratePreset preset;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SubstratePresetCard({
    super.key,
    required this.preset,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? const Color(0xFF003D4C) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: preset.icon == 'usual_mix' 
                          ? const Color(0xFFE8F5E9) 
                          : const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconData(preset.icon),
                      color: preset.icon == 'usual_mix' 
                          ? const Color(0xFF4CAF50) 
                          : const Color(0xFFFF9800),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Title and Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003D4C),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${preset.materials.length} materials · ${preset.greensCount} greens / ${preset.brownsCount} browns',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Action buttons
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: onEdit,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F7F9),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F7F9),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 16),
              
              // Materials wrap
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: preset.materials.map((m) => _buildMaterialTag(m)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialTag(SubstrateMaterial material) {
    final bgColor = material.isNitrogenRich 
        ? const Color(0xFFE8F5E9) 
        : const Color(0xFFF9F1E7);
    final textColor = material.isNitrogenRich 
        ? const Color(0xFF4CAF50) 
        : const Color(0xFF8D6E63);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        material.label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'usual_mix':
        return Icons.eco_outlined;
      case 'heavy_carbon':
        return Icons.energy_savings_leaf_outlined;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}
