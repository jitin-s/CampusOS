import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../campus_fix/presentation/controllers/campus_fix_controller.dart';
import '../../../lost_found/presentation/controllers/lost_found_controller.dart';
import '../../../queue/presentation/controllers/queue_controller.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final issues = context.watch<CampusFixController>().issues;
    final items = context.watch<LostFoundController>().items;
    final token = context.watch<QueueController>().activeToken;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Activity Timeline',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Unified stream of all your requests and status updates across CampusOS.',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (token != null)
            _TimelineItem(
              title: 'Active Queue Token #${token.tokenNumber}',
              subtitle:
                  'Joined service queue • Status: ${token.status.name.toUpperCase()}',
              time: 'Recently',
              icon: Icons.confirmation_number_outlined,
              iconColor: AppTheme.accentOrange,
            ),
          for (final issue in issues)
            _TimelineItem(
              title: 'CampusFix: ${issue.category} - ${issue.type}',
              subtitle:
                  'Location: ${issue.locationId} • Status: ${issue.status.name.toUpperCase()}',
              time:
                  '${issue.createdAt.day}/${issue.createdAt.month} ${issue.createdAt.hour}:${issue.createdAt.minute.toString().padLeft(2, '0')}',
              icon: Icons.build_circle_outlined,
              iconColor: AppTheme.primaryBlue,
            ),
          for (final item in items)
            _TimelineItem(
              title: '${item.itemType.name.toUpperCase()}: ${item.itemName}',
              subtitle:
                  'Location: ${item.location} • Status: ${item.status.name.toUpperCase()}',
              time: '${item.createdAt.day}/${item.createdAt.month}',
              icon: Icons.find_in_page_outlined,
              iconColor: AppTheme.statusResolved,
            ),
          if (token == null && issues.isEmpty && items.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No active timeline activity yet.'),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconColor;

  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Text(
          time,
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
        ),
      ),
    );
  }
}
