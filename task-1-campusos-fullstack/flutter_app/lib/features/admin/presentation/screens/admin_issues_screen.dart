import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/issue_entity.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminIssuesScreen extends StatelessWidget {
  const AdminIssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminDashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('CampusFix Issue Triage & Management'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.secondaryNavy,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.issues.length,
        itemBuilder: (context, index) {
          final issue = controller.issues[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ticket #${issue.id} • ${issue.category}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Chip(
                        label: Text(
                          issue.status.name.toUpperCase(),
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: _getStatusColor(issue.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Location: ${issue.locationId} • Type: ${issue.type}'),
                  const SizedBox(height: 6),
                  Text(
                    issue.description,
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Assigned: ${issue.assignedTo ?? "Unassigned"} (${issue.departmentId ?? "Pending"})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showQuickAction(context, issue),
                        child: const Text('Dispatch / Progress'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(IssueStatus status) {
    switch (status) {
      case IssueStatus.resolved:
      case IssueStatus.studentVerified:
      case IssueStatus.closed:
        return const Color(0xFFDCFCE7);
      case IssueStatus.assigned:
      case IssueStatus.inProgress:
        return const Color(0xFFDBEAFE);
      default:
        return const Color(0xFFFEF3C7);
    }
  }

  void _showQuickAction(BuildContext context, IssueEntity issue) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Quick Progress Action for #${issue.id}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.engineering,
                color: AppTheme.statusAssigned,
              ),
              title: const Text('Mark In Progress'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<AdminDashboardController>().updateIssueStatus(
                  issueId: issue.id,
                  newStatus: IssueStatus.inProgress,
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
                color: AppTheme.statusResolved,
              ),
              title: const Text('Mark Resolved (Field Completed)'),
              onTap: () {
                Navigator.pop(ctx);
                context.read<AdminDashboardController>().updateIssueStatus(
                  issueId: issue.id,
                  newStatus: IssueStatus.resolved,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
