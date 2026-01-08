import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (int index) {
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        indicatorColor: Colors.purpleAccent.withValues(alpha: 0.2),
        height: 90.0,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined, color: Colors.white60, size: 28),
            selectedIcon: Text(
              'Wallfeed',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Colors.purpleAccent,
                letterSpacing: 1.2,
              ),
            ),
            label: 'Wallfeed',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined, color: Colors.white60, size: 28),
            selectedIcon: Text(
              'Create',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.purpleAccent,
                letterSpacing: 1.2,
              ),
            ),
            label: 'Create',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline, color: Colors.white60, size: 28),
            selectedIcon: Text(
              'Profile',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: Colors.purpleAccent,
                letterSpacing: 1.2,
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
