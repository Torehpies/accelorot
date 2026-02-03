import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/status_badge.dart';

class DataCard<T> extends StatelessWidget {
  final IconData icon;
  final Color? iconBgColor;
  final Color? iconColor;
  final String title;
  final String? description;
  final String? category;
  final String status;
  final String? userName;
  final Color? statusColor;
  final Color? statusTextColor;
  final VoidCallback? onTap;
  final T data;

  const DataCard({
    super.key,
    required this.icon,
    this.iconBgColor,
    required this.title,
    this.description,
    this.category,
    required this.status,
    this.userName,
    this.statusColor,
    this.statusTextColor,
    required this.data,
    this.onTap,
    this.iconColor,
  });

  bool get _hasCategory => category?.isNotEmpty == true;
  bool get _hasDescription => description?.isNotEmpty == true;
  bool get _hasUserName => userName?.isNotEmpty == true;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.background2,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.grey, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor ?? AppColors.green100,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor ?? Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_hasCategory) StatusBadge(status: category!),
                      ],
                    ),
                    if (_hasDescription) ...[
                      const SizedBox(height: 4),
                      Text(
                        description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (_hasDescription || _hasCategory)
                      const SizedBox(height: 12),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor ?? AppColors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusTextColor ?? AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (_hasUserName)
                          Flexible(
                            child: Text(
                              'by $userName',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}