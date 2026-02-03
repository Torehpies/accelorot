// lib/ui/web_operator/widgets/tabs_row.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';

class TabsRow extends StatelessWidget {
  final TabController? controller;

  const TabsRow({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 40,
      child: Theme(
        data: theme.copyWith(
          tabBarTheme: theme.tabBarTheme.copyWith(dividerHeight: 0),
        ),
        child: TabBar(
          controller: controller,
          isScrollable: true,
          labelPadding: const EdgeInsets.only(right: 16),
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 3, color: WebColors.greenAccent),
            insets: EdgeInsets.symmetric(horizontal: 16),
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          labelColor: WebColors.textHeading,
          unselectedLabelColor: WebColors.textMuted,
          labelStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('Members'),
              ),
            ),
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('For Approval'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}