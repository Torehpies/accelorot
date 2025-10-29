import 'package:flutter/material.dart';
import 'package:flutter_application_1/routes/navigation_utils.dart';

class ResponsiveWebShell extends StatelessWidget {
  final Widget child;
  final List<NavItem> navItems;
  final Color primaryColor;
  final Color secondaryColor;
  final String roleName;
  final Widget brandingWidget;
  final double sidebarWidth;

  const ResponsiveWebShell({
    super.key,
    required this.child,
    required this.navItems,
    required this.primaryColor,
    required this.secondaryColor,
    required this.roleName,
    required this.brandingWidget,
    this.sidebarWidth = 250,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = getSelectedIndex(context, navItems);

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: sidebarWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  brandingWidget,
                  const Divider(color: Colors.white30, height: 32),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: navItems.length,
                      itemBuilder: (context, index) {
                        final item = navItems[index];
                        final isSelected = selectedIndex == index;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              leading: Icon(
                                item.icon,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                size: 22,
                              ),
                              title: Text(
                                item.label,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white70,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                              selected: isSelected,
                              selectedTileColor: Colors.white.withValues(
                                alpha: .15,
                              ),
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
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.logout, color: primaryColor),
                      label: Text(
                        'Logout',
                        style: TextStyle(color: primaryColor),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Use centralized handler
                      onPressed: () => handleLogout(
                        context,
                        roleName: roleName,
                        confirmColor:
                            secondaryColor, // Use the darker color for confirmation button
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
