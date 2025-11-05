// lib/widgets/operator_detail_panel.dart

import 'package:flutter/material.dart';
import '../models/operator_model.dart';
import '../../utils/theme_constants.dart';

class OperatorDetailPanel extends StatelessWidget {
  final OperatorModel operator;
  final VoidCallback onClose;
  final VoidCallback? onArchive;
  final VoidCallback? onRestore;
  final VoidCallback? onViewDashboard;
  final VoidCallback? onRemovePermanently;
  final bool showArchived;

  const OperatorDetailPanel({
    super.key,
    required this.operator,
    required this.onClose,
    this.onArchive,
    this.onRestore,
    this.onViewDashboard,
    this.onRemovePermanently,
    required this.showArchived,
  });

  @override
  Widget build(BuildContext context) {
    final hasLeft = operator.hasLeft;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius20),
        border: Border.all(color: ThemeConstants.greyShade300, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Close Button
          Padding(
            padding: const EdgeInsets.all(ThemeConstants.spacing12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Operator Details',
                  style: TextStyle(
                    fontSize: ThemeConstants.fontSize16,
                    fontWeight: FontWeight.bold,
                    color: ThemeConstants.tealShade600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  iconSize: ThemeConstants.iconSize20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeConstants.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: ThemeConstants.tealShade100,
                            borderRadius: BorderRadius.circular(ThemeConstants.borderRadius16),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: ThemeConstants.tealShade700,
                          ),
                        ),
                        const SizedBox(height: ThemeConstants.spacing12),
                        Text(
                          operator.name,
                          style: const TextStyle(
                            fontSize: ThemeConstants.fontSize18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: ThemeConstants.spacing8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: ThemeConstants.spacing12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeConstants.tealShade50,
                            borderRadius: BorderRadius.circular(ThemeConstants.borderRadius8),
                            border: Border.all(color: ThemeConstants.tealShade200),
                          ),
                          child: Text(
                            operator.role,
                            style: TextStyle(
                              color: ThemeConstants.tealShade800,
                              fontWeight: FontWeight.w600,
                              fontSize: ThemeConstants.fontSize12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: ThemeConstants.spacing24),
                  
                  // Information Section
                  Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: ThemeConstants.fontSize14,
                      fontWeight: FontWeight.bold,
                      color: ThemeConstants.greyShade700,
                    ),
                  ),
                  const SizedBox(height: ThemeConstants.spacing12),
                  
                  _buildDetailRow(
                    Icons.email_outlined,
                    'Email Address',
                    operator.email,
                  ),
                  const SizedBox(height: ThemeConstants.spacing16),
                  
                  _buildDetailRow(
                    Icons.calendar_today_outlined,
                    'Date Added',
                    operator.formatDate(operator.addedAt),
                  ),
                  
                  if (operator.isArchived) ...[
                    const SizedBox(height: ThemeConstants.spacing16),
                    _buildDetailRow(
                      Icons.archive_outlined,
                      'Archived Date',
                      operator.formatDate(operator.archivedAt),
                    ),
                  ],
                  
                  const SizedBox(height: ThemeConstants.spacing24),
                  
                  // Status Section
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: ThemeConstants.fontSize14,
                      fontWeight: FontWeight.bold,
                      color: ThemeConstants.greyShade700,
                    ),
                  ),
                  const SizedBox(height: ThemeConstants.spacing12),
                  
                  Container(
                    padding: const EdgeInsets.all(ThemeConstants.spacing12),
                    decoration: BoxDecoration(
                      color: hasLeft
                          ? Colors.red.shade50
                          : operator.isArchived 
                              ? ThemeConstants.orangeShade50 
                              : ThemeConstants.greenShade50,
                      borderRadius: BorderRadius.circular(ThemeConstants.borderRadius8),
                      border: Border.all(
                        color: hasLeft
                            ? Colors.red.shade600
                            : operator.isArchived 
                                ? ThemeConstants.orangeShade600 
                                : ThemeConstants.greenShade600,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          hasLeft 
                              ? Icons.person_off 
                              : operator.isArchived 
                                  ? Icons.archive 
                                  : Icons.check_circle,
                          color: hasLeft
                              ? Colors.red.shade600
                              : operator.isArchived 
                                  ? ThemeConstants.orangeShade600 
                                  : ThemeConstants.greenShade600,
                          size: ThemeConstants.iconSize18,
                        ),
                        const SizedBox(width: ThemeConstants.spacing8),
                        Expanded(
                          child: Text(
                            hasLeft 
                                ? 'Permanently Removed' 
                                : operator.isArchived 
                                    ? 'Archived' 
                                    : 'Active',
                            style: TextStyle(
                              color: hasLeft
                                  ? Colors.red.shade600
                                  : operator.isArchived 
                                      ? ThemeConstants.orangeShade600 
                                      : ThemeConstants.greenShade600,
                              fontWeight: FontWeight.w600,
                              fontSize: ThemeConstants.fontSize13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Additional info for permanently removed operators
                  if (hasLeft && operator.leftAt != null) ...[
                    const SizedBox(height: ThemeConstants.spacing12),
                    Container(
                      padding: const EdgeInsets.all(ThemeConstants.spacing12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.red.shade600,
                            size: ThemeConstants.iconSize18,
                          ),
                          const SizedBox(width: ThemeConstants.spacing8),
                          Expanded(
                            child: Text(
                              'This operator was permanently removed on ${operator.formatDate(operator.leftAt)} and cannot be restored.',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: ThemeConstants.fontSize12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          // Action Buttons at Bottom
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(ThemeConstants.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // View Dashboard Button (for both active and archived)
                if (onViewDashboard != null) ...[
                  ElevatedButton.icon(
                    onPressed: onViewDashboard,
                    icon: const Icon(Icons.dashboard, size: ThemeConstants.iconSize18),
                    label: const Text(
                      'View Dashboard',
                      style: TextStyle(fontSize: ThemeConstants.fontSize14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.tealShade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius10),
                      ),
                    ),
                  ),
                  const SizedBox(height: ThemeConstants.spacing12),
                ],
                
                // Archive Button (only for active operators)
                if (!showArchived && !hasLeft && onArchive != null) ...[
                  ElevatedButton.icon(
                    onPressed: onArchive,
                    icon: const Icon(Icons.archive, size: ThemeConstants.iconSize18),
                    label: const Text(
                      'Archive',
                      style: TextStyle(fontSize: ThemeConstants.fontSize14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.orangeShade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius10),
                      ),
                    ),
                  ),
                  const SizedBox(height: ThemeConstants.spacing12),
                ],
                
                // Remove Permanently Button (only for active operators)
                if (!showArchived && !hasLeft && onRemovePermanently != null) ...[
                  OutlinedButton.icon(
                    onPressed: onRemovePermanently,
                    icon: const Icon(Icons.delete_forever, size: ThemeConstants.iconSize18),
                    label: const Text(
                      'Remove Permanently',
                      style: TextStyle(fontSize: ThemeConstants.fontSize14),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius10),
                      ),
                    ),
                  ),
                ],
                
                // Restore Button (only for archived operators who haven't left)
                if (showArchived && !hasLeft && onRestore != null) ...[
                  ElevatedButton.icon(
                    onPressed: onRestore,
                    icon: const Icon(Icons.restore, size: ThemeConstants.iconSize18),
                    label: const Text(
                      'Restore',
                      style: TextStyle(fontSize: ThemeConstants.fontSize14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConstants.tealShade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ThemeConstants.borderRadius10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: ThemeConstants.greyShade100,
            borderRadius: BorderRadius.circular(ThemeConstants.borderRadius8),
          ),
          child: Icon(icon, color: ThemeConstants.greyShade700, size: ThemeConstants.iconSize18),
        ),
        const SizedBox(width: ThemeConstants.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ThemeConstants.fontSize11,
                  color: ThemeConstants.greyShade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: ThemeConstants.fontSize13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}