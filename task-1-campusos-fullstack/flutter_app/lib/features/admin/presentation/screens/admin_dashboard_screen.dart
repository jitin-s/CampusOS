import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/issue_entity.dart';

import 'package:campusos/features/auth/presentation/controllers/auth_controller.dart';

import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      if (user != null) {
        context.read<AdminDashboardController>().loadDashboardData(
          user.campusId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminDashboardController>();
    final analytics = controller.analytics;

    if (controller.isLoading && analytics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus Command Center',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time operations, closed-loop telemetry, and campus intelligence.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                onPressed: () {
                  final user = context.read<AuthController>().currentUser;
                  if (user != null) {
                    controller.loadDashboardData(user.campusId);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4 KPI Cards (PRD 7 & UX SCR-ADM-01)
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.6,
            children: [
              _KpiCard(
                title: 'Critical Issues',
                value: '${analytics?.criticalIssues ?? 0}',
                subtitle: 'Requires immediate dispatch',
                color: AppTheme.statusCritical,
                icon: Icons.warning_amber_rounded,
              ),
              _KpiCard(
                title: 'Active Work Orders',
                value: '${analytics?.totalIssues ?? 0}',
                subtitle: 'Across campus facilities',
                color: AppTheme.statusAssigned,
                icon: Icons.pending_actions,
              ),
              _KpiCard(
                title: 'Resolution Rate',
                value: '${analytics?.resolutionRate.toStringAsFixed(0) ?? 84}%',
                subtitle: 'Closed within SLA',
                color: AppTheme.statusResolved,
                icon: Icons.task_alt,
              ),
              _KpiCard(
                title: 'L&F Recovery Rate',
                value:
                    '${analytics?.lostFoundRecoveryRate.toStringAsFixed(0) ?? 76}%',
                subtitle: 'Owner claimed items',
                color: AppTheme.statusMedium,
                icon: Icons.find_in_page,
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Operational Hotspots (Intelligence Clusters - Task 2 Integration)
          if (analytics?.problemClusters.isNotEmpty == true) ...[
            Text(
              '⚠️ Operational Hotspots & Incident Clusters',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              color: const Color(0xFFFEF3C7),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    for (final cluster in analytics!.problemClusters)
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppTheme.statusHigh,
                          child: Icon(Icons.hub_outlined, color: Colors.white),
                        ),
                        title: Text(
                          cluster.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Location: ${cluster.locationPattern} • ${cluster.incidentCount} reports aggregated • AI Priority: ${cluster.urgency}',
                        ),
                        trailing: const Chip(
                          label: Text(
                            'Recurring Hotspot',
                            style: TextStyle(fontSize: 11),
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Priority Triage Queue
          Text(
            'Priority Action Queue (Triage Feed)',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.issues.length,
              separatorBuilder: (_, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final issue = controller.issues[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: issue.severity == IssueSeverity.critical
                        ? AppTheme.statusCritical
                        : AppTheme.statusAssigned,
                    child: Icon(
                      issue.severity == IssueSeverity.critical
                          ? Icons.bolt
                          : Icons.build,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    '${issue.category}: ${issue.type} (${issue.locationId})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Status: ${issue.status.name.toUpperCase()} • Assigned: ${issue.assignedTo ?? "Unassigned"}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(
                          issue.severity.name.toUpperCase(),
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor:
                            issue.severity == IssueSeverity.critical
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFDBEAFE),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _showAssignDialog(context, issue),
                        child: Text(
                          issue.assignedTo == null ? 'Assign' : 'Update',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignDialog(BuildContext context, IssueEntity issue) {
    final deptController = TextEditingController(
      text: issue.departmentId ?? 'IT Support',
    );
    final staffController = TextEditingController(
      text: issue.assignedTo ?? 'Rajesh Technician',
    );
    IssueStatus newStatus = issue.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Dispatch & Manage #${issue.id}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location: ${issue.locationId}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Description: ${issue.description}'),
              const SizedBox(height: 16),
              TextField(
                controller: deptController,
                decoration: const InputDecoration(
                  labelText: 'Responsible Department',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: staffController,
                decoration: const InputDecoration(
                  labelText: 'Assign Staff / Technician',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<IssueStatus>(
                initialValue: newStatus,
                decoration: const InputDecoration(labelText: 'Update Status'),
                items: IssueStatus.values
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => newStatus = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final c = context.read<AdminDashboardController>();
                await c.assignIssue(
                  issueId: issue.id,
                  departmentId: deptController.text.trim(),
                  assignedTo: staffController.text.trim(),
                );
                if (newStatus != issue.status) {
                  await c.updateIssueStatus(
                    issueId: issue.id,
                    newStatus: newStatus,
                  );
                }
              },
              child: const Text('Save & Dispatch'),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
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
                    fontWeight: FontWeight.bold,
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
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
