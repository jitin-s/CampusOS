import 'package:uuid/uuid.dart';

import '../../core/network/supabase_client_manager.dart';
import '../../domain/entities/notice_entity.dart';
import '../../domain/repositories/notice_repository.dart';
import '../models/notice_model.dart';

class SupabaseNoticeRepository implements NoticeRepository {
  final SupabaseClientManager _clientManager;
  final List<NoticeEntity> _mockNotices = [];

  SupabaseNoticeRepository({SupabaseClientManager? clientManager})
    : _clientManager = clientManager ?? SupabaseClientManager.instance {
    _initMockData();
  }

  void _initMockData() {
    _mockNotices.addAll([
      NoticeModel(
        id: 'not-001',
        campusId: 'campus-alpha-001',
        authorId: 'admin-001',
        title: 'Mid-Term Examination Schedule Released',
        category: 'Examination',
        body: 'The Fall semester mid-term examination timetable has been published on the student portal. Review your exam room allocations.',
        priority: 'Important',
        deadline: DateTime.now().add(const Duration(days: 5)),
        publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
        isActive: true,
      ),
      NoticeModel(
        id: 'not-002',
        campusId: 'campus-alpha-001',
        authorId: 'admin-001',
        title: 'Semester Tuition Fee Payment Deadline Extended',
        category: 'Fees',
        body: 'Students are advised that the deadline for clearing semester dues without late penalty is extended to October 25th.',
        priority: 'Important',
        deadline: DateTime.now().add(const Duration(days: 14)),
        publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        isActive: true,
      ),
      NoticeModel(
        id: 'not-003',
        campusId: 'campus-alpha-001',
        authorId: 'admin-002',
        title: 'Annual Campus Hackathon & Tech Fest 2026',
        category: 'Event',
        body: 'Registrations are open for teams across engineering and design departments. Exciting prizes and mentorship opportunities.',
        priority: 'General',
        deadline: DateTime.now().add(const Duration(days: 10)),
        publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        isActive: true,
      ),
    ]);
  }

  @override
  Future<List<NoticeEntity>> getNotices({
    required String campusId,
    String? category,
  }) async {
    final client = _clientManager.client;
    if (client != null) {
      var query = client
          .from('notices')
          .select()
          .eq('campus_id', campusId)
          .eq('active', true);
      if (category != null && category.toLowerCase() != 'all') {
        query = query.eq('category', category);
      }
      final response = await query.order('published_at', ascending: false);
      return (response as List)
          .map((item) => NoticeModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    await Future.delayed(const Duration(milliseconds: 150));
    var results = _mockNotices.where(
      (e) => e.campusId == campusId && e.isActive,
    );
    if (category != null && category.toLowerCase() != 'all') {
      results = results.where(
        (e) => e.category.toLowerCase() == category.toLowerCase(),
      );
    }
    return results.toList();
  }

  @override
  Future<NoticeEntity> createNotice(NoticeEntity notice) async {
    final newId = 'not-${const Uuid().v4().substring(0, 6)}';
    final model = NoticeModel(
      id: newId,
      campusId: notice.campusId,
      authorId: notice.authorId,
      title: notice.title,
      category: notice.category,
      body: notice.body,
      priority: notice.priority,
      deadline: notice.deadline,
      publishedAt: DateTime.now(),
      isActive: true,
    );

    final client = _clientManager.client;
    if (client != null) {
      await client.from('notices').insert(model.toJson());
      return model;
    }

    await Future.delayed(const Duration(milliseconds: 200));
    _mockNotices.insert(0, model);
    return model;
  }
}
