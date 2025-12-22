import 'package:flutter/material.dart';

class TabsRow extends StatelessWidget {
  const TabsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 36,
      child: TabBar(
        isScrollable: true, // so they don’t stretch
        labelPadding: const EdgeInsets.only(right: 8),
        indicator: BoxDecoration(
          color: const Color(0xFFE0F2FF),
          borderRadius: BorderRadius.circular(18),
        ),
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: Colors.grey[600],
        overlayColor:
            WidgetStateProperty.all(Colors.transparent),
        tabs: const [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Active'),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('For Approval'),
            ),
          ),
        ],
      ),
    );
  }
}
