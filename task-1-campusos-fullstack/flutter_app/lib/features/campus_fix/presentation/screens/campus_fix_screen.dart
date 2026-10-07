import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/issue_entity.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/campus_fix_controller.dart';
import '../widgets/issue_status_stepper.dart';

class CampusFixScreen extends StatefulWidget {
  const CampusFixScreen({super.key});

  @override
  State<CampusFixScreen> createState() => _CampusFixScreenState();
}

class _CampusFixScreenState extends State<CampusFixScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      if (user != null) {
        context.read<CampusFixController>().loadIssues(
          campusId: user.campusId,
          reporterId: user.id,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryBlue,
            indicatorColor: AppTheme.primaryBlue,
            tabs: const [
              Tab(icon: Icon(Icons.list_alt), text: 'My Issues'),
              Tab(
                icon: Icon(Icons.add_circle_outline),
                text: 'Report New Issue',
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MyIssuesList(onNewReportTapped: () => _tabController.animateTo(1)),
          _ReportIssueForm(onSuccess: () => _tabController.animateTo(0)),
        ],
      ),
    );
  }
}

class _MyIssuesList extends StatelessWidget {
  final VoidCallback onNewReportTapped;

  const _MyIssuesList({required this.onNewReportTapped});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CampusFixController>();

    if (controller.isLoading && controller.issues.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.issues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No reported issues found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Have a facility or equipment problem? Report it now.'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onNewReportTapped,
              icon: const Icon(Icons.add),
              label: const Text('Report Issue'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.issues.length,
      itemBuilder: (context, index) {
        final issue = controller.issues[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: _getSeverityColor(issue.severity),
              child: const Icon(Icons.build, color: Colors.white, size: 18),
            ),
            title: Text(
              '${issue.category} - ${issue.type}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Location: ${issue.locationId} • Status: ${issue.status.name.toUpperCase()}',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            childrenPadding: const EdgeInsets.all(16),
            children: [
              Text(issue.description, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Workflow Progress Tracker',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              IssueStatusStepper(currentStatus: issue.status),
              if (issue.status == IssueStatus.resolved) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    await context.read<CampusFixController>().verifyResolution(
                      issue.id,
                    );
                  },
                  icon: const Icon(Icons.verified),
                  label: const Text('Confirm Resolution & Close'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.statusResolved,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getSeverityColor(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.critical:
        return AppTheme.statusCritical;
      case IssueSeverity.high:
        return AppTheme.statusHigh;
      case IssueSeverity.medium:
        return AppTheme.statusMedium;
      case IssueSeverity.low:
        return AppTheme.statusPending;
    }
  }
}

class _ReportIssueForm extends StatefulWidget {
  final VoidCallback onSuccess;

  const _ReportIssueForm({required this.onSuccess});

  @override
  State<_ReportIssueForm> createState() => _ReportIssueFormState();
}

class _ReportIssueFormState extends State<_ReportIssueForm> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'Equipment';
  final _typeController = TextEditingController(text: 'Projector');
  final _locationController = TextEditingController(text: 'Room 204');
  final _descriptionController = TextEditingController();
  IssueSeverity _severity = IssueSeverity.high;

  final List<String> _categories = [
    'Classroom',
    'Electrical',
    'Wi-Fi',
    'Equipment',
    'Cleanliness',
    'Water',
    'Hostel',
    'Other',
  ];

  @override
  void dispose() {
    _typeController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthController>().currentUser;
    if (user == null) return;

    final controller = context.read<CampusFixController>();
    final issue = await controller.reportIssue(
      campusId: user.campusId,
      reporterId: user.id,
      category: _category,
      type: _typeController.text.trim(),
      description: _descriptionController.text.trim(),
      locationId: _locationController.text.trim(),
      severity: _severity,
    );

    if (issue != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Issue #${issue.id} submitted successfully!'),
          backgroundColor: AppTheme.statusResolved,
        ),
      );
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Submit Issue Request',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _category = val ?? 'Equipment'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _typeController,
                  decoration: const InputDecoration(
                    labelText: 'Issue Type / Item',
                    hintText: 'e.g. Projector, Light Switch, Water Cooler',
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Campus Location',
                    hintText:
                        'e.g. Room 204, Library 1st Floor, Hostel Block B',
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<IssueSeverity>(
                  initialValue: _severity,
                  decoration: const InputDecoration(
                    labelText: 'Severity Level',
                  ),
                  items: IssueSeverity.values
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.name.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) =>
                      setState(() => _severity = val ?? IssueSeverity.medium),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Problem Description',
                    hintText:
                        'Describe what is wrong and any visible indicators...',
                  ),
                  validator: (v) => (v == null || v.length < 5)
                      ? 'Please describe the issue'
                      : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit to Campus Maintenance'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
