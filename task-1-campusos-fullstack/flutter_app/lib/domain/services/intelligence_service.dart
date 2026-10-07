import '../entities/intelligence_models.dart';
import '../entities/issue_entity.dart';
import '../entities/lost_found_entity.dart';

/// Contract interface connecting Task-1 application layer to Task-2 Intelligence algorithms
abstract class IntelligenceService {
  /// Calculate similarity between a lost item and a found item
  MatchResultModel calculateMatch(
    LostFoundItemEntity lostItem,
    LostFoundItemEntity foundItem,
  );

  /// Automatically classify an issue text and context
  ClassificationResultModel classifyIssue(
    String title,
    String description,
    String location,
  );

  /// Calculate explainable priority score for an issue
  PriorityResultModel calculatePriority(
    String category,
    IssueSeverity severity,
    String location, {
    int affectedUsers = 1,
    int recurrenceCount = 1,
  });

  /// Group multiple issues into localized problem clusters
  List<IssueClusterModel> clusterIssues(List<IssueEntity> issues);

  /// Calculate high-level campus operational metrics and reliability index
  CampusAnalyticsModel calculateCampusAnalytics({
    required List<IssueEntity> issues,
    required List<LostFoundItemEntity> lostItems,
    required List<LostFoundItemEntity> foundItems,
  });
}
