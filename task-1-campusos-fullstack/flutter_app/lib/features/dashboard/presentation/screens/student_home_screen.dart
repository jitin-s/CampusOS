import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _ActionCard(
                icon: Icons.build_circle_outlined,
                title: 'Report Issue',
                subtitle: 'CampusFix',
                color: AppTheme.primaryBlue,
                onTap: () => context.go('/student/campus-fix'),
              ),
              _ActionCard(
                icon: Icons.find_in_page_outlined,
                title: 'Lost & Found',
                subtitle: 'Track or Claim',
                color: AppTheme.accentOrange,
                onTap: () => context.go('/student/lost-found'),
              ),
              _ActionCard(
                icon: Icons.confirmation_number_outlined,
                title: 'Join Queue',
                subtitle: 'Digital Token',
                color: AppTheme.statusAssigned,
                onTap: () => context.go('/student/queue'),
              ),
              _ActionCard(
                icon: Icons.notifications_none,
                title: 'Notices',
                subtitle: 'Campus Bulletins',
                color: AppTheme.statusResolved,
                onTap: () => context.go('/student/notices'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'My Active Requests',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.statusAssigned,
                child: Icon(Icons.build, color: Colors.white, size: 20),
              ),
              title: const Text('Broken Projector (Room 204)'),
              subtitle: const Text('Status: Assigned to IT Maintenance'),
              trailing: const Chip(
                label: Text('In Progress', style: TextStyle(fontSize: 12)),
                backgroundColor: Color(0xFFDBEAFE),
              ),
              onTap: () => context.go('/student/activity'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Campus Status',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.statusResolved,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Campus Systems Operational',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Wi-Fi, Library, and Academic labs operating normally.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
