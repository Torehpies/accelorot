import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/web_colors.dart';
import 'package:flutter_application_1/ui/core/themes/web_text_styles.dart';

class TabsRow extends StatelessWidget {
  final TabController? controller;
  final List<String> tabTitles;

  const TabsRow({super.key, this.controller, required this.tabTitles});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 32,
      child: Theme(
        data: theme.copyWith(
          tabBarTheme: theme.tabBarTheme.copyWith(dividerHeight: 0),
        ),
        child: TabBar(
          controller: controller,
          isScrollable: true,
          labelPadding: const EdgeInsets.only(right: 16),
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 2, color: WebColors.greenAccent),
            insets: EdgeInsets.symmetric(horizontal: 16),
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          labelStyle: WebTextStyles.sectionTitle,
          unselectedLabelStyle: WebTextStyles.sectionTitle.copyWith(
            fontWeight: FontWeight.w600,
            color: WebColors.textMuted,
          ),
          tabs:
              tabTitles // Dynamically create tabs from `tabTitles`
                  .map(
                    (title) => Tab(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(title),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
