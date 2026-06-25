import 'package:flutter/material.dart';

import '../screens/feedback_screen.dart';
import '../screens/home_screen.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({required this.selectedRoute, super.key});

  final String selectedRoute;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.ink,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.spa_outlined, color: Colors.white, size: 30),
                    SizedBox(height: 16),
                    Text(
                      'Masaj',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Feedback center',
                      style: TextStyle(
                        color: Color(0xFFC9D8D3),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _DrawerItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                routeName: HomeScreen.routeName,
                selectedRoute: selectedRoute,
              ),
              _DrawerItem(
                icon: Icons.rate_review_outlined,
                selectedIcon: Icons.rate_review,
                label: 'Feedback',
                routeName: FeedbackScreen.routeName,
                selectedRoute: selectedRoute,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.mint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline, color: AppTheme.teal),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Private team inbox',
                        style: TextStyle(
                          color: AppTheme.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.routeName,
    required this.selectedRoute,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String routeName;
  final String selectedRoute;

  @override
  Widget build(BuildContext context) {
    final isSelected = routeName == selectedRoute;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: AppTheme.mint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? AppTheme.teal : AppTheme.mutedInk,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.teal : AppTheme.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        onTap: () {
          Navigator.of(context).pop();
          if (!isSelected) {
            Navigator.of(context).pushReplacementNamed(routeName);
          }
        },
      ),
    );
  }
}
