import 'package:flutter/material.dart';

class DataBottomSheet<T> extends StatelessWidget {
  final T data;
  final String title;
  final List<MapEntry<String, String>> details;
  final IconData? avatarIcon;
  final Color? avatarColor;
  final List<Widget>? actions;
  final String? primaryActionLabel;
  final void Function(T)? onPrimaryAction;

  const DataBottomSheet({
    super.key,
    required this.data,
    required this.title,
    required this.details,
    this.avatarIcon,
    this.avatarColor,
    this.actions,
    this.primaryActionLabel,
    this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Row(
              children: [
                if (avatarIcon != null)
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: avatarColor ?? Colors.blue.shade100,
                    child: Icon(avatarIcon, color: Colors.white),
                  ),
                if (avatarIcon != null) SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // if (details.isNotEmpty)
                      //   Text(
                      //     details.first.value,
                      //     style: TextStyle(color: Colors.grey.shade600),
                      //     maxLines: 1,
                      //     overflow: TextOverflow.ellipsis,
                      //   ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            // Scrollable details
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: details
                      .map((entry) => _detailRow(entry.key, entry.value))
                      .toList(),
                ),
              ),
            ),
            // Actions
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                      label: Text('Close'),
                    ),
                  ),
                  if (primaryActionLabel != null) ...[
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onPrimaryAction?.call(data);
                        },
                        icon: Icon(Icons.edit),
                        label: Text(primaryActionLabel!),
                      ),
                    ),
                  ],
                  if (actions != null) ...[
                    SizedBox(width: 12),
                    ...actions!.map(
                      (action) => SizedBox(width: 80, child: action),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
