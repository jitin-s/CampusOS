import '../../domain/entities/lost_found_entity.dart';

class LostFoundItemModel extends LostFoundItemEntity {
  const LostFoundItemModel({
    required super.id,
    required super.campusId,
    required super.userId,
    required super.itemType,
    required super.category,
    required super.itemName,
    super.brand,
    super.color,
    required super.location,
    required super.occurredAt,
    required super.description,
    super.imageUrl,
    required super.status,
    required super.createdAt,
  });

  factory LostFoundItemModel.fromJson(Map<String, dynamic> json) {
    return LostFoundItemModel(
      id: json['id'] as String? ?? '',
      campusId: json['campus_id'] as String? ?? 'campus-alpha-001',
      userId: json['user_id'] as String? ?? '',
      itemType: (json['item_type'] as String?)?.toLowerCase() == 'found'
          ? ItemType.found
          : ItemType.lost,
      category: json['category'] as String? ?? 'General',
      itemName: json['item_name'] as String? ?? '',
      brand: json['brand'] as String?,
      color: json['color'] as String?,
      location: json['location'] as String? ?? '',
      occurredAt: json['occurred_at'] != null
          ? DateTime.parse(json['occurred_at'] as String)
          : DateTime.now(),
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      status: ItemStatus.values.firstWhere(
        (e) =>
            e.name.toLowerCase() == (json['status'] as String?)?.toLowerCase(),
        orElse: () => ItemStatus.open,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campus_id': campusId,
      'user_id': userId,
      'item_type': itemType.name,
      'category': category,
      'item_name': itemName,
      'brand': brand,
      'color': color,
      'location': location,
      'occurred_at': occurredAt.toIso8601String(),
      'description': description,
      'image_url': imageUrl,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
