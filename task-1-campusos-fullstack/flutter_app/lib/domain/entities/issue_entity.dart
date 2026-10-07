import 'package:flutter/foundation.dart';

/// Issue severity enum
enum IssueSeverity {
  low,
  medium,
  high,
  critical;

  static IssueSeverity fromString(String? val) {
    return IssueSeverity.values.firstWhere(
      (e) => e.name.toLowerCase() == val?.toLowerCase(),
      orElse: () => IssueSeverity.medium,
    );
  }
}

/// Issue workflow status enum per docs/02_SRD.md Section 5
enum IssueStatus {
  reported,
  verified,
  assigned,
  inProgress,
  resolved,
  studentVerified,
  closed;

  static IssueStatus fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'verified':
        return IssueStatus.verified;
      case 'assigned':
        return IssueStatus.assigned;
      case 'in_progress':
      case 'inprogress':
        return IssueStatus.inProgress;
      case 'resolved':
        return IssueStatus.resolved;
      case 'student_verified':
      case 'studentverified':
        return IssueStatus.studentVerified;
      case 'closed':
        return IssueStatus.closed;
      case 'reported':
      default:
        return IssueStatus.reported;
    }
  }

  String toDbValue() {
    switch (this) {
      case IssueStatus.inProgress:
        return 'in_progress';
      case IssueStatus.studentVerified:
        return 'student_verified';
      default:
        return name;
    }
  }
}

/// CampusFix Issue entity with campus_id
@immutable
class IssueEntity {
  final String id;
  final String campusId;
  final String reporterId;
  final String category;
  final String type;
  final String description;
  final String locationId;
  final IssueSeverity severity;
  final String? departmentId;
  final String? assignedTo;
  final IssueStatus status;
  final String? beforeImageUrl;
  final String? afterImageUrl;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final DateTime? verifiedAt;

  const IssueEntity({
    required this.id,
    required this.campusId,
    required this.reporterId,
    required this.category,
    required this.type,
    required this.description,
    required this.locationId,
    required this.severity,
    this.departmentId,
    this.assignedTo,
    required this.status,
    this.beforeImageUrl,
    this.afterImageUrl,
    required this.createdAt,
    this.resolvedAt,
    this.verifiedAt,
  });
}
