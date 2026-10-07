import '../../domain/entities/queue_entity.dart';

class QueueModel extends QueueEntity {
  const QueueModel({
    required super.id,
    required super.campusId,
    required super.serviceName,
    required super.location,
    required super.isActive,
    required super.currentToken,
    required super.waitingCount,
  });

  factory QueueModel.fromJson(Map<String, dynamic> json) {
    return QueueModel(
      id: json['id'] as String? ?? '',
      campusId: json['campus_id'] as String? ?? 'campus-alpha-001',
      serviceName: json['service_name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      currentToken: json['current_token'] as int? ?? 1,
      waitingCount: json['waiting_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campus_id': campusId,
      'service_name': serviceName,
      'location': location,
      'is_active': isActive,
      'current_token': currentToken,
      'waiting_count': waitingCount,
    };
  }
}

class QueueTokenModel extends QueueTokenEntity {
  const QueueTokenModel({
    required super.id,
    required super.queueId,
    required super.userId,
    required super.tokenNumber,
    required super.status,
    required super.joinedAt,
    super.servedAt,
  });

  factory QueueTokenModel.fromJson(Map<String, dynamic> json) {
    return QueueTokenModel(
      id: json['id'] as String? ?? '',
      queueId: json['queue_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      tokenNumber: json['token_number'] as int? ?? 1,
      status: TokenStatus.values.firstWhere(
        (e) =>
            e.name.toLowerCase() == (json['status'] as String?)?.toLowerCase(),
        orElse: () => TokenStatus.waiting,
      ),
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : DateTime.now(),
      servedAt: json['served_at'] != null
          ? DateTime.parse(json['served_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queue_id': queueId,
      'user_id': userId,
      'token_number': tokenNumber,
      'status': status.name,
      'joined_at': joinedAt.toIso8601String(),
      'served_at': servedAt?.toIso8601String(),
    };
  }
}
