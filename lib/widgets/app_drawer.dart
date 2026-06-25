import 'package:flutter/material.dart';

import '../screens/feedback_screen.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({required this.selectedRoute, super.key});

  final String selectedRoute;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.sizeOf(context).width * 0.74,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 36, 16, 28),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.border,
                    backgroundImage: const AssetImage(
                      'assets/images/drawer_avatar.png',
                    ),
                  ),
                  const SizedBox(width: 18),
                  const Expanded(
                    child: Text(
                      'Jane Doe',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppTheme.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 26),
                children: [
                  _DrawerMenuItem(
                    icon: Icons.person_outline,
                    title: 'Profile',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.workspace_premium_outlined,
                    title: 'AI Coach',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.insert_chart_outlined,
                    title: 'Insights',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.fact_check_outlined,
                    title: 'Check-In',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.attach_file,
                    title: 'My Files',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.chat_bubble_outline,
                    title: 'Feedback',
                    isSelected: selectedRoute == FeedbackScreen.routeName,
                    onTap: () {
                      Navigator.pop(context);
                      if (selectedRoute != FeedbackScreen.routeName) {
                        Navigator.pushNamed(context, FeedbackScreen.routeName);
                      }
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.hub_outlined,
                    title: 'Refer A Friend',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.favorite_border,
                    title: 'Help/Support',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _DrawerMenuItem(
                    icon: Icons.hexagon_outlined,
                    title: 'Settings',
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppTheme.border),
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 18),
              child: ListTile(
                minLeadingWidth: 40,
                leading: const Icon(
                  Icons.logout,
                  color: AppTheme.error,
                  size: 28,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 10,
      minTileHeight: 58,
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryDark : AppTheme.primaryText,
        size: 28,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppTheme.primaryDark : AppTheme.primaryText,
        ),
      ),
      onTap: onTap,
    );
  }
}
