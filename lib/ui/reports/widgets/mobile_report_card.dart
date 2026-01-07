import 'package:flutter/material.dart';
import '../../../data/models/report.dart';
import '../../../ui/core/themes/web_colors.dart';

class MobileReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;

  const MobileReportCard({
    super.key,
    required this.report,
    required this.onTap,
  });

  Color get statusColor {
    switch (report.status.toLowerCase()) {
      case 'open':
        return Colors.blue.shade100;
      case 'in_progress':
        return Colors.amber.shade100;
      case 'completed':
        return Colors.green.shade100;
      case 'on_hold':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color get statusTextColor {
    switch (report.status.toLowerCase()) {
      case 'open':
        return Colors.blue.shade700;
      case 'in_progress':
        return Colors.amber.shade800;
      case 'completed':
        return Colors.green.shade800;
      case 'on_hold':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  Color get priorityColor {
    switch (report.priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Expanded(
                    child: Text(
                      report.title.isNotEmpty ? report.title : 'No Title',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937), // dark gray
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit_outlined, size: 18, color: Colors.blueGrey[300]),
                  const SizedBox(width: 8),
                  Icon(Icons.open_in_new, size: 18, color: Colors.blueGrey[300]),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // Category
              Text(
                report.reportTypeLabel,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Status and Priority
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      report.statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusTextColor, 
                      ),
                    ),
                  ),
                  
                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: priorityColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      report.priorityLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: priorityColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
