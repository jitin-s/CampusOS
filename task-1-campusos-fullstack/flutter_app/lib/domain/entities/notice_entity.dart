import 'package:flutter/foundation.dart';

@immutable
class NoticeEntity {
  final String id;
  final String campusId;
  final String authorId;
  final String title;
  final String category;
  final String body;
  final String priority;
  final DateTime? deadline;
  final DateTime publishedAt;
  final bool isActive;

  const NoticeEntity({
    required this.id,
    required this.campusId,
    required this.authorId,
    required this.title,
    required this.category,
    required this.body,
    required this.priority,
    this.deadline,
    required this.publishedAt,
    required this.isActive,
  });
}
