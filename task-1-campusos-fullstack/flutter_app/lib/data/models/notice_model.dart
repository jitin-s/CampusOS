import '../../domain/entities/notice_entity.dart';

class NoticeModel extends NoticeEntity {
  const NoticeModel({
    required super.id,
    required super.campusId,
    required super.authorId,
    required super.title,
    required super.category,
    required super.body,
    required super.priority,
    super.deadline,
    required super.publishedAt,
    required super.isActive,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] as String? ?? '',
      campusId: json['campus_id'] as String? ?? 'campus-alpha-001',
      authorId: json['author_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      body: json['body'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Normal',
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : DateTime.now(),
      isActive: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campus_id': campusId,
      'author_id': authorId,
      'title': title,
      'category': category,
      'body': body,
      'priority': priority,
      'deadline': deadline?.toIso8601String(),
      'published_at': publishedAt.toIso8601String(),
      'active': isActive,
    };
  }
}
