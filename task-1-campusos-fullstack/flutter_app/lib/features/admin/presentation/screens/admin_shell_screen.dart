import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:campusos/core/theme/app_theme.dart';
import 'package:campusos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:campusos/features/sos/presentation/widgets/sos_app_bar_button.dart';

class AdminShellScreen extends StatelessWidget {
  final Widget child;

  const AdminShellScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/admin/dashboard')) return 0;
    if (location.startsWith('/admin/issues')) return 1;
    if (location.startsWith('/admin/lost-found')) return 2;
    if (location.startsWith('/admin/queues')) return 3;
    if (location.startsWith('/admin/notices')) return 4;
    if (location.startsWith('/admin/analytics')) return 5;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/admin/dashboard');
        break;
      case 1:
        context.go('/admin/issues');
        break;
      case 2:
        context.go('/admin/lost-found');
        break;
      case 3:
        context.go('/admin/queues');
        break;
      case 4:
        context.go('/admin/notices');
        break;
      case 5:
        context.go('/admin/analytics');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    final selectedIndex = _calculateSelectedIndex(context);
    final user = context.watch<AuthController>().currentUser;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundCream,
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield_outlined, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CampusOS Admin Command Console',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'FACILITIES, OPERATIONS & EMERGENCY DISPATCH',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            // Switch to Student View Button for convenience
            TextButton.icon(
              onPressed: () => context.go('/student/home'),
              icon: const Icon(Icons.school, size: 16, color: Colors.white70),
              label: const Text(
                'Student View',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),

            // Emergency SOS Monitor Button
            const SosAppBarButton(),

            const SizedBox(width: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, color: AppTheme.campusGreenBorder, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      user?.name ?? 'Administrator',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: () async {
                await context.read<AuthController>().logout();
                if (context.mounted) context.go('/login');
              },
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: Colors.white,
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              labelType: NavigationRailLabelType.all,
              indicatorColor: AppTheme.primaryBlue.withOpacity(0.15),
              selectedIconTheme: const IconThemeData(color: AppTheme.primaryBlue),
              selectedLabelTextStyle: const TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.build_outlined),
                  selectedIcon: Icon(Icons.build),
                  label: Text('Issues'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(Icons.search),
                  label: Text('Lost & Found'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Queues'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.notifications_none),
                  selectedIcon: Icon(Icons.notifications),
                  label: Text('Notices'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: Text('Analytics'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1, color: AppTheme.creamBorder),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Text('CampusOS Admin'),
        actions: [
          const SosAppBarButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthController>().logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            label: 'Issues',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            label: 'L&F',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Queues',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            label: 'Notices',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
