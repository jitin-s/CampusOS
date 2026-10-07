import '../../domain/entities/issue_entity.dart';

class IssueModel extends IssueEntity {
  const IssueModel({
    required super.id,
    required super.campusId,
    required super.reporterId,
    required super.category,
    required super.type,
    required super.description,
    required super.locationId,
    required super.severity,
    super.departmentId,
    super.assignedTo,
    required super.status,
    super.beforeImageUrl,
    super.afterImageUrl,
    required super.createdAt,
    super.resolvedAt,
    super.verifiedAt,
  });

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    return IssueModel(
      id: json['id'] as String? ?? '',
      campusId: json['campus_id'] as String? ?? 'campus-alpha-001',
      reporterId: json['reporter_id'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      type: json['type'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      locationId: json['location_id'] as String? ?? '',
      severity: IssueSeverity.fromString(json['severity'] as String?),
      departmentId: json['department_id'] as String?,
      assignedTo: json['assigned_to'] as String?,
      status: IssueStatus.fromString(json['status'] as String?),
      beforeImageUrl: json['before_image_url'] as String?,
      afterImageUrl: json['after_image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campus_id': campusId,
      'reporter_id': reporterId,
      'category': category,
      'type': type,
      'description': description,
      'location_id': locationId,
      'severity': severity.name,
      'department_id': departmentId,
      'assigned_to': assignedTo,
      'status': status.toDbValue(),
      'before_image_url': beforeImageUrl,
      'after_image_url': afterImageUrl,
      'created_at': createdAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
    };
  }
}
