import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

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
            borderSide: BorderSide(width: 3, color: AppColors.green100),
            insets: EdgeInsets.symmetric(horizontal: 16),
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
          labelColor: theme.colorScheme.onSurface,
          unselectedLabelColor: Colors.grey,
          labelStyle: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: theme.textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'Members',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'For Approval',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
