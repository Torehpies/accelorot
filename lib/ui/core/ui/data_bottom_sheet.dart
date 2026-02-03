import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

class DataBottomSheet<T> extends StatelessWidget {
  final T data;
  final String title;
  final List<MapEntry<String, String>> details;
  final IconData? avatarIcon;
  final Color? avatarColor;
  final List<Widget>? actions;
  final String? primaryActionLabel;
  final IconData? primaryActionIcon;
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
    this.primaryActionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
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
                if (avatarIcon != null) const SizedBox(width: 16),
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
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
            // Polished Actions
            _ActionBar(
              primaryActionLabel: primaryActionLabel,
              primaryActionIcon: primaryActionIcon,
              onPrimaryAction: () {
                onPrimaryAction?.call(data);
              },
              actions: actions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

class _ActionBar extends StatelessWidget {
  final String? primaryActionLabel;
  final IconData? primaryActionIcon;
  final VoidCallback? onPrimaryAction;
  final List<Widget>? actions;

  const _ActionBar({
    this.primaryActionLabel,
    this.primaryActionIcon,
    this.onPrimaryAction,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 32),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final hasPrimary = primaryActionLabel != null;
          final totalButtons = (actions?.length ?? 0) + (hasPrimary ? 1 : 0);

          if (totalButtons == 0) return const SizedBox(height: 20);

          if (totalButtons == 1) {
            return _buildSingleButton(screenWidth);
          }

          final idealWidth = (screenWidth - 24) / totalButtons;
          final buttonWidth = idealWidth.clamp(120.0, 160.0);

          if (totalButtons > 3) {
            return _buildScrollableRow(buttonWidth);
          }

          return _buildEqualWidthRow(buttonWidth);
        },
      ),
    );
  }

  Widget _buildSingleButton(double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPrimaryAction,
          icon: Icon(primaryActionIcon ?? Icons.edit, size: 20),
          label: Text(
            primaryActionLabel!,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green100,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            shadowColor: Colors.black26,
          ),
        ),
      ),
    );
  }

  Widget _buildEqualWidthRow(double buttonWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(child: _buildActionsRow(buttonWidth)),
          // Primary button - LEFT aligned, prominent
          if (primaryActionLabel != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildPrimaryButton(),
              ),
            ),

          // Actions - equal space
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return ElevatedButton.icon(
      onPressed: onPrimaryAction,
      icon: Icon(primaryActionIcon ?? Icons.edit),
      label: Text(primaryActionLabel!, style: const TextStyle(fontSize: 15)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.green100,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildActionsRow(double buttonWidth) {
    if (actions == null || actions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: actions!
          .map(
            (action) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  child: action,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildScrollableRow(double buttonWidth) {
    final children = <Widget>[];

    if (primaryActionLabel != null) {
      children.add(_buildPrimaryButton());
      children.add(const SizedBox(width: 12));
    }

    if (actions != null) {
      children.addAll(
        actions!.map(
          (action) => SizedBox(
            width: buttonWidth,
            height: 52,
            child: DefaultTextStyle(
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              child: action,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: children),
    );
  }
}
