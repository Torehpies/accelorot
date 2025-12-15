// lib/ui/mobile_admin_home/widgets/operator_card.dart

import 'package:flutter/material.dart';
import '../../../data/models/operator_model.dart';
import '../widgets/status_indicator.dart';

class OperatorCard extends StatelessWidget {
  final OperatorModel operator;
  final VoidCallback? onTap;

  const OperatorCard({super.key, required this.operator, this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth > 600 ? 120.0 : constraints.maxWidth * 0.3;
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: cardWidth.clamp(90, 120),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400, width: 1),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(color: Colors.teal.shade50, shape: BoxShape.circle),
                        child: const Icon(Icons.person, size: 40, color: Colors.teal),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          operator.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Positioned(top: 4, right: 4, child: StatusIndicator(isArchived: operator.isArchived, size: 12)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}