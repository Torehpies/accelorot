import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';
import 'package:flutter_application_1/ui/core/themes/app_theme.dart';

class ResponsiveWebShell extends StatelessWidget {
  final Widget child;
  final List<NavItem> navItems;
  final Color color;
  final String roleName;
  final Widget brandingWidget;
  final double sidebarWidth;

  const ResponsiveWebShell({
    super.key,
    required this.child,
    required this.navItems,
    required this.color,
    required this.roleName,
    required this.brandingWidget,
    this.sidebarWidth = 250,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = getSelectedIndex(context, navItems);
    const smallWidth = 75.0;

    final isTablet =
        MediaQuery.of(context).size.width >= kTabletBreakpoint &&
        MediaQuery.of(context).size.width < kDesktopBreakpoint;
    final isDesktop = MediaQuery.of(context).size.width >= kDesktopBreakpoint;

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: isTablet ? smallWidth : sidebarWidth,
            color: color,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 6, 0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    brandingWidget,
                    SizedBox(height: isDesktop ? 32 : 25),
                    Expanded(
                      child: ListView.builder(
                        itemCount: navItems.length,
                        itemBuilder: (context, index) {
                          final item = navItems[index];
                          final isSelected = selectedIndex == index;

                          if (isTablet) {
                            return Tooltip(
                              message: item.label,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 4),
                                height: 48,
                                child: Material(
                                  color: isSelected
                                      ? AppColors.green100
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () => goToPathByIndex(
                                      context,
                                      index,
                                      navItems,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        item.icon,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                                leading: Icon(
                                  item.icon,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  size: isTablet ? 20 : 22,
                                ),
                                title: isDesktop
                                    ? Text(
                                        item.label,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      )
                                    : null,
                                selected: isSelected,
                                selectedTileColor: AppColors.green100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                onTap: () =>
                                    goToPathByIndex(context, index, navItems),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    isTablet
                        ? Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            child: ElevatedButton(
                              onPressed: () => handleLogout(
                                context,
                                roleName: roleName,
                                confirmColor: AppColors.error,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(12),
                                minimumSize: const Size(48, 48),
                              ),
                              child: Icon(
                                Icons.logout,
                                size: 20,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.all(20),
                            child: ElevatedButton.icon(
                              icon: Icon(
                                Icons.logout,
                                color: AppColors.textPrimary,
                              ),
                              label: Text(
                                'Logout',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.background,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              // Use centralized handler
                              onPressed: () => handleLogout(
                                context,
                                roleName: roleName,
                                confirmColor: AppColors.error,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
