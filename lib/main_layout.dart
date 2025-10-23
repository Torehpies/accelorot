// lib/frontend/screens/main_layout.dart

import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  final List<Widget> screens;
  final List<BottomNavigationBarItem> navItems;

  const MainLayout({
    Key? key,
    required this.screens,
    required this.navItems,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;

  @override
  void initState() {
    _currentIndex = widget.initialIndex;
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Detect screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Threshold: 600px is common for mobile vs tablet/web
    final bool isMobile = screenWidth < 600;

    final currentScreen = widget.screens[_currentIndex];
    final navItems = widget.navItems;

    if (isMobile) {
      // Mobile: Bottom Navigation
      return Scaffold(
        body: currentScreen,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: navItems,
          type: BottomNavigationBarType.fixed, // Prevent shifting on iOS
        ),
      );
    } else {
      // Web/Desktop: Permanent Sidebar
      return Scaffold(
        appBar: AppBar(
          title: const Text('My App'),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              ...List.generate(
                navItems.length,
                (index) => ListTile(
                  leading: navItems[index].icon,
                  title: Text(navItems[index].label!),
                  selected: _currentIndex == index,
                  onTap: () {
                    _onItemTapped(index);
                    Navigator.of(context).pop(); // Close drawer on web (optional)
                  },
                ),
              ),
            ],
          ),
        ),
        body: Row(
          children: [
            // Permanent sidebar (not a modal drawer)
            SizedBox(
              width: 250,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: List.generate(
                  navItems.length,
                  (index) => ListTile(
                    leading: navItems[index].icon,
                    title: Text(navItems[index].label!),
                    selected: _currentIndex == index,
                    onTap: () => _onItemTapped(index),
                  ),
                ),
              ),
            ),
            Expanded(child: currentScreen),
          ],
        ),
      );
    }
  }
}