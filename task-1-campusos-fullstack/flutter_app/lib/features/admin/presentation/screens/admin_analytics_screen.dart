import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminDashboardController>();
    final analytics = controller.analytics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Operational Intelligence & Analytics'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.secondaryNavy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campus Reliability Score
            Card(
              color: AppTheme.secondaryNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E3E62),
                      ),
                      child: Center(
                        child: Text(
                          '${analytics?.campusReliabilityScore ?? 88}',
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Campus Reliability Index',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Algorithmic composite score based on MTTR, resolution rate, and critical defect frequency.',
                            style: TextStyle(
                              color: Colors.grey[400],
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
            const SizedBox(height: 24),

            // Performance KPIs
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'Mean Time to Resolve',
                    value: '${analytics?.averageResolutionHours ?? 3.4} hrs',
                    icon: Icons.timer_outlined,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    label: 'Workflow SLA Rate',
                    value:
                        '${analytics?.resolutionRate.toStringAsFixed(1) ?? 84.0}%',
                    icon: Icons.check_circle_outline,
                    color: AppTheme.statusResolved,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    label: 'Lost & Found Rate',
                    value:
                        '${analytics?.lostFoundRecoveryRate.toStringAsFixed(1) ?? 76.0}%',
                    icon: Icons.find_in_page_outlined,
                    color: AppTheme.statusMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Department Distribution
            Text(
              'Operational Distribution by Department',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _BarRow(
                      label: 'IT & Equipment Maintenance',
                      percentage: 0.42,
                      count: 14,
                    ),
                    _BarRow(
                      label: 'Facilities & Electrical',
                      percentage: 0.28,
                      count: 9,
                    ),
                    _BarRow(
                      label: 'Sanitation & Cleanliness',
                      percentage: 0.18,
                      count: 6,
                    ),
                    _BarRow(
                      label: 'Estate & Civil Works',
                      percentage: 0.12,
                      count: 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Recurring Clusters
            Text(
              'Recurring Defect Clusters (Task-2 ML/Intelligence Engine)',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (analytics?.problemClusters.isNotEmpty == true)
              for (final cluster in analytics!.problemClusters)
                Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.statusHigh,
                      child: Icon(Icons.hub, color: Colors.white),
                    ),
                    title: Text(
                      cluster.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Co-located incidents: ${cluster.incidentCount} • AI Priority: ${cluster.urgency} • Area: ${cluster.locationPattern}',
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final String label;
  final double percentage;
  final int count;

  const _BarRow({
    required this.label,
    required this.percentage,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              Text(
                '$count incidents (${(percentage * 100).toInt()}%)',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[200],
            color: AppTheme.primaryBlue,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
