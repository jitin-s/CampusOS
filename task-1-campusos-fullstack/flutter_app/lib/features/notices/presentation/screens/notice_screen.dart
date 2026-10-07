import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/notice_entity.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/notice_controller.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  final List<String> _categories = [
    'All',
    'Important',
    'Examination',
    'Fees',
    'Academic',
    'Event',
    'Hostel',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      if (user != null) {
        context.read<NoticeController>().loadNotices(campusId: user.campusId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final controller = context.watch<NoticeController>();

    return Column(
      children: [
        // Category Pills (UX Spec Section 10)
        Container(
          color: Colors.white,
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = controller.selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: const Color(0xFFDBEAFE),
                  checkmarkColor: AppTheme.primaryBlue,
                  onSelected: (_) {
                    if (user != null) {
                      controller.filterCategory(user.campusId, cat);
                    }
                  },
                ),
              );
            },
          ),
        ),
        Expanded(
          child: controller.isLoading && controller.notices.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : controller.notices.isEmpty
              ? const Center(
                  child: Text('No notices available in this category.'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.notices.length,
                  itemBuilder: (context, index) {
                    final notice = controller.notices[index];
                    return _NoticeCard(notice: notice);
                  },
                ),
        ),
      ],
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final NoticeEntity notice;

  const _NoticeCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    final isImportant =
        notice.priority.toLowerCase() == 'important' ||
        notice.priority.toLowerCase() == 'critical';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isImportant
            ? const BorderSide(color: AppTheme.statusHigh, width: 1.5)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    notice.category.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: const Color(0xFFF1F5F9),
                  visualDensity: VisualDensity.compact,
                ),
                if (isImportant)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'IMPORTANT',
                      style: TextStyle(
                        color: AppTheme.statusCritical,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notice.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              notice.body,
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
            ),
            const SizedBox(height: 12),
            if (notice.deadline != null) ...[
              const Divider(),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.event_available,
                    size: 16,
                    color: AppTheme.accentOrange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Deadline: ${notice.deadline!.day}/${notice.deadline!.month}/${notice.deadline!.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentOrange,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
