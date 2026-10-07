import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operational Overview',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time campus operational activity and intelligence',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          // Metrics Cards from docs/04_UX_DESIGN.md Section 12
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: const [
              _MetricCard(
                title: 'Critical Issues',
                value: '2',
                color: AppTheme.statusCritical,
                icon: Icons.warning_amber_rounded,
              ),
              _MetricCard(
                title: 'Active Issues',
                value: '14',
                color: AppTheme.statusAssigned,
                icon: Icons.pending_actions,
              ),
              _MetricCard(
                title: 'Resolved Today',
                value: '8',
                color: AppTheme.statusResolved,
                icon: Icons.task_alt,
              ),
              _MetricCard(
                title: 'Recovery Rate',
                value: '76%',
                color: AppTheme.statusMedium,
                icon: Icons.find_in_page,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Priority Action Queue',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.statusCritical,
                    child: Icon(Icons.bolt, color: Colors.white),
                  ),
                  title: Text('Power Outage - Block B Lab 3'),
                  subtitle: Text('Reported 12m ago • Priority: CRITICAL'),
                  trailing: Chip(
                    label: Text(
                      'Unassigned',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: AppTheme.statusCritical,
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.statusHigh,
                    child: Icon(Icons.videocam_off, color: Colors.white),
                  ),
                  title: Text('Projector Malfunction - Room 204'),
                  subtitle: Text('Reported 45m ago • Priority: HIGH'),
                  trailing: Chip(
                    label: Text('Assigned: IT', style: TextStyle(fontSize: 12)),
                    backgroundColor: Color(0xFFDBEAFE),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
