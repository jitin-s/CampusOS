import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:campusos/features/auth/presentation/controllers/auth_controller.dart';

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
        appBar: AppBar(
          title: const Text('CampusOS Admin Console'),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text('Admin: ${user?.name ?? "Administrator"}'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: () async {
                await context.read<AuthController>().logout();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  label: Text('Overview'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.build_outlined),
                  label: Text('Issues'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search_outlined),
                  label: Text('Lost & Found'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outline),
                  label: Text('Queues'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.notifications_none),
                  label: Text('Notices'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.analytics_outlined),
                  label: Text('Analytics'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusOS Admin'),
        actions: [
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
