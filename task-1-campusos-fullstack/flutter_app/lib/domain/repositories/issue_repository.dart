import '../entities/issue_entity.dart';

/// Segregated repository contract for CampusFix issues (Interface Segregation & Dependency Inversion)
abstract class IssueRepository {
  Future<List<IssueEntity>> getIssues({
    required String campusId,
    String? reporterId,
    IssueStatus? status,
  });

  Future<IssueEntity> getIssueById(String id);

  Future<IssueEntity> createIssue({
    required String campusId,
    required String reporterId,
    required String category,
    required String type,
    required String description,
    required String locationId,
    required IssueSeverity severity,
    String? beforeImageUrl,
  });

  Future<IssueEntity> updateStatus({
    required String issueId,
    required IssueStatus newStatus,
    String? afterImageUrl,
  });

  Future<IssueEntity> assignIssue({
    required String issueId,
    required String departmentId,
    required String assignedTo,
  });
}
