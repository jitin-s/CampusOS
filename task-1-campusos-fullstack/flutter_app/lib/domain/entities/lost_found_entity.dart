import 'package:flutter/foundation.dart';

enum ItemType { lost, found }

enum ItemStatus { open, matched, claimed, recovered, closed }

@immutable
class LostFoundItemEntity {
  final String id;
  final String campusId;
  final String userId;
  final ItemType itemType;
  final String category;
  final String itemName;
  final String? brand;
  final String? color;
  final String location;
  final DateTime occurredAt;
  final String description;
  final String? imageUrl;
  final ItemStatus status;
  final DateTime createdAt;

  const LostFoundItemEntity({
    required this.id,
    required this.campusId,
    required this.userId,
    required this.itemType,
    required this.category,
    required this.itemName,
    this.brand,
    this.color,
    required this.location,
    required this.occurredAt,
    required this.description,
    this.imageUrl,
    required this.status,
    required this.createdAt,
  });
}
