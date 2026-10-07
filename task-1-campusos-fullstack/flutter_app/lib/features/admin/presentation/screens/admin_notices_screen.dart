import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/notice_entity.dart';

import 'package:campusos/features/auth/presentation/controllers/auth_controller.dart';

import '../controllers/admin_dashboard_controller.dart';

class AdminNoticesScreen extends StatefulWidget {
  const AdminNoticesScreen({super.key});

  @override
  State<AdminNoticesScreen> createState() => _AdminNoticesScreenState();
}

class _AdminNoticesScreenState extends State<AdminNoticesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _category = 'Examination';
  String _priority = 'Important';

  final List<String> _categories = [
    'Academic',
    'Examination',
    'Fees',
    'Event',
    'Placement',
    'Hostel',
    'Emergency',
    'General',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthController>().currentUser;
    if (user == null) return;

    final notice = NoticeEntity(
      id: '',
      campusId: user.campusId,
      authorId: user.id,
      title: _titleController.text.trim(),
      category: _category,
      body: _bodyController.text.trim(),
      priority: _priority,
      deadline: DateTime.now().add(const Duration(days: 7)),
      publishedAt: DateTime.now(),
      isActive: true,
    );

    await context.read<AdminDashboardController>().publishNotice(notice);
    if (mounted) {
      _titleController.clear();
      _bodyController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notice broadcast successfully!'),
          backgroundColor: AppTheme.statusResolved,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminDashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publish Campus Notices & Bulletins'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.secondaryNavy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Broadcast Official Notice',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Bulletin Title',
                          hintText:
                              'e.g. Schedule Released, Emergency Water Repair',
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _category,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                              ),
                              items: _categories
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _category = val ?? 'General'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _priority,
                              decoration: const InputDecoration(
                                labelText: 'Priority Level',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Normal',
                                  child: Text('Normal Priority'),
                                ),
                                DropdownMenuItem(
                                  value: 'Important',
                                  child: Text('🔴 Important Banner'),
                                ),
                              ],
                              onChanged: (val) =>
                                  setState(() => _priority = val ?? 'Normal'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bodyController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Detailed Notice Text',
                          hintText:
                              'Detailed content for students and faculty...',
                        ),
                        validator: (v) => (v == null || v.length < 10)
                            ? 'Must contain descriptive text'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Publish Notice to Campus'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Broadcasts',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final notice in controller.notices)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    notice.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${notice.category} • Priority: ${notice.priority}',
                  ),
                  trailing: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
