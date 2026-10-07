import '../entities/notice_entity.dart';

abstract class NoticeRepository {
  Future<List<NoticeEntity>> getNotices({
    required String campusId,
    String? category,
  });
  Future<NoticeEntity> createNotice(NoticeEntity notice);
}
