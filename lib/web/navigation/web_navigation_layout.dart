

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/web/admin/screens/web_login_screen.dart';
import 'package:flutter_application_1/web/navigation/nav_item.dart';

class WebNavigationLayout extends StatelessWidget {
  final int selectedIndex;
  final List<Widget> screens;
  final List<NavItem> navItems;
  final ValueChanged<int> onItemSelected;

  const WebNavigationLayout({
    super.key,
    required this.selectedIndex,
    required this.screens,
    required this.navItems,
    required this.onItemSelected,
  });

  void _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WebLoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(context),
          // Content Area
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 1,
                title: Text(
                  navItems[selectedIndex].label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle),
                    onPressed: () => onItemSelected(5),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: Container(
                color: Colors.grey[50],
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: screens[selectedIndex],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF1ABC9C),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.speed,
                      color: Color(0xFF1ABC9C),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Accel-O-Rot',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white30, height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: navItems.length,
                itemBuilder: (context, index) {
                  final item = navItems[index];
                  final isLogout = index == navItems.length - 1;
                  final isSelected = selectedIndex == index && !isLogout;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: ListTile(
                      leading: Icon(
                        item.icon,
                        color: Colors.white,
                        size: 22,
                      ),
                      title: Text(
                        item.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.white,
                      selectedTileColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      onTap: () {
                        if (isLogout) {
                          _handleLogout(context);
                        } else {
                          onItemSelected(index);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}