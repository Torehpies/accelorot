import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';
import 'package:flutter_application_1/ui/web_operator/widgets/status_badge.dart';

class DataCard<T> extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String? description;
  final String? descriptionTitle;
  final String? category;
  final String? categoryTitle;
  final Color? categoryColor;
  final Color? categoryTextColor;
  final String status;
  final String? userName;
  final Color? statusColor;
  final Color? statusTextColor;
  final void Function(String action, T data)? onAction;
  final T data;
  final bool showActions;

  const DataCard({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.title,
    this.description,
    this.descriptionTitle,
    this.category,
    this.categoryTitle,
    this.categoryColor,
    this.categoryTextColor,
    required this.status,
    this.userName,
    this.statusColor,
    this.statusTextColor,
    required this.data,
    this.onAction,
    this.showActions = false,
  });

  bool get _hasDescription => description?.isNotEmpty == true;
  bool get _hasCategory => category?.isNotEmpty == true;
  bool get _hasUserName => userName?.isNotEmpty == true;

  void _handleAction(String action) {
    onAction?.call(action, data);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onAction?.call('view', data),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
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
                        Container(
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
                          ),
                        ),
                        const Spacer(),
                        if (_hasUserName)
                          Text(
                            'by $userName',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (showActions)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _handleAction('accept'),
                        icon: Icon(Icons.check_circle_outline, size: 16),
                        label: Text('Accept', style: TextStyle(fontSize: 12)),
                      ),
                      TextButton.icon(
                        onPressed: () => _handleAction('decline'),
                        icon: Icon(Icons.cancel_outlined, size: 16),
                        label: Text('Decline', style: TextStyle(fontSize: 12)),
                      ),
                      TextButton.icon(
                        onPressed: () => _handleAction('edit'),
                        icon: Icon(Icons.edit_outlined, size: 16),
                        label: Text('Edit', style: TextStyle(fontSize: 12)),
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
