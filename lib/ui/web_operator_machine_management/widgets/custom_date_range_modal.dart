import 'package:flutter/material.dart';

class CustomDateRangeModal extends StatelessWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;
  final bool isDesktop;
  final bool isTablet;
  final bool isMobile;

  const CustomDateRangeModal({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onDateRangeSelected,
    required this.isDesktop,
    required this.isTablet,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : (isTablet ? 40 : 16),
        vertical: isDesktop ? 80 : (isTablet ? 40 : 16),
      ),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    DateTime? tempStartDate = initialStartDate ?? DateTime.now().subtract(const Duration(days: 7));
    DateTime? tempEndDate = initialEndDate ?? DateTime.now();

    return StatefulBuilder(
      builder: (context, setState) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 500 : (isTablet ? 400 : 350),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.1 * 255).round()),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 24 : (isTablet ? 20 : 16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Date Range',
                        style: TextStyle(
                          fontSize: isDesktop ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Date selection section
                  Column(
                    children: [
                      // Start Date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'From',
                            style: TextStyle(
                              fontSize: isDesktop ? 14 : 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: tempStartDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: tempEndDate ?? DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors.blue,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                      onSurface: Colors.black,
                                    ),
                                    dialogTheme: const DialogThemeData(
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  tempStartDate = picked;
                                });
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tempStartDate != null
                                        ? '${tempStartDate!.day}/${tempStartDate!.month}/${tempStartDate!.year}'
                                        : 'Select Start Date',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 14 : 13,
                                      color: tempStartDate != null
                                          ? Colors.black
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // End Date
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'To',
                            style: TextStyle(
                              fontSize: isDesktop ? 14 : 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: tempEndDate ?? DateTime.now(),
                                firstDate: tempStartDate ?? DateTime(2020),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData(
                                      useMaterial3: true,
                                      colorScheme: const ColorScheme.light(
                                        primary: Colors.blue,
                                        surface: Colors.white,
                                      ),
                                      dialogTheme: const DialogThemeData(
                                        backgroundColor: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setState(() {
                                  tempEndDate = picked;
                                });
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    tempEndDate != null
                                        ? '${tempEndDate!.day}/${tempEndDate!.month}/${tempEndDate!.year}'
                                        : 'Select End Date',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 14 : 13,
                                      color: tempEndDate != null
                                          ? Colors.black
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Quick select buttons
                  Text(
                    'Quick Select',
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickSelectButton(
                        context,
                        'Last 7 Days',
                        () {
                          setState(() {
                            tempEndDate = DateTime.now();
                            tempStartDate = DateTime.now().subtract(const Duration(days: 7));
                          });
                        },
                      ),
                      _buildQuickSelectButton(
                        context,
                        'This Month',
                        () {
                          final now = DateTime.now();
                          setState(() {
                            tempStartDate = DateTime(now.year, now.month, 1);
                            tempEndDate = now;
                          });
                        },
                      ),
                      _buildQuickSelectButton(
                        context,
                        'Last Month',
                        () {
                          final now = DateTime.now();
                          final lastMonth = DateTime(now.year, now.month - 1, 1);
                          setState(() {
                            tempStartDate = lastMonth;
                            tempEndDate = DateTime(now.year, now.month, 0);
                          });
                        },
                      ),
                      _buildQuickSelectButton(
                        context,
                        'This Year',
                        () {
                          final now = DateTime.now();
                          setState(() {
                            tempStartDate = DateTime(now.year, 1, 1);
                            tempEndDate = now;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: isDesktop ? 14 : 13,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: tempStartDate != null && tempEndDate != null
                              ? () {
                                  onDateRangeSelected(tempStartDate, tempEndDate);
                                  Navigator.pop(context);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: Colors.blue,
                            disabledBackgroundColor: Colors.grey.shade300,
                          ),
                          child: Text(
                            'Apply Filter',
                            style: TextStyle(
                              fontSize: isDesktop ? 14 : 13,
                              color: Colors.white,
                            ),
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
      },
    );
  }

  Widget _buildQuickSelectButton(BuildContext context, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 13 : 12,
            color: const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}