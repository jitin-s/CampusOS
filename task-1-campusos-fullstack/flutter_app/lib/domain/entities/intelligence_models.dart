/// Data models representing outputs from Campus Intelligence Engine.
class MatchResultModel {
  final int score;
  final String strength;
  final List<String> matchedAttributes;
  final bool isStrongMatch;

  const MatchResultModel({
    required this.score,
    required this.strength,
    required this.matchedAttributes,
    required this.isStrongMatch,
  });

  factory MatchResultModel.fromScore(int score, List<String> matchedAttrs) {
    String strength = 'Weak match';
    if (score >= 80) {
      strength = 'Strong potential match';
    } else if (score >= 60) {
      strength = 'Moderate potential match';
    }
    return MatchResultModel(
      score: score,
      strength: strength,
      matchedAttributes: matchedAttrs,
      isStrongMatch: score >= 75,
    );
  }
}

class ClassificationResultModel {
  final String category;
  final String subcategory;
  final String department;
  final double confidence;

  const ClassificationResultModel({
    required this.category,
    required this.subcategory,
    required this.department,
    required this.confidence,
  });
}

class PriorityResultModel {
  final String level; // LOW, MEDIUM, HIGH, CRITICAL
  final int score;
  final List<String> explanation;

  const PriorityResultModel({
    required this.level,
    required this.score,
    required this.explanation,
  });
}

class IssueClusterModel {
  final String clusterId;
  final String title;
  final String primaryCategory;
  final String locationPattern;
  final int incidentCount;
  final String urgency;
  final List<String> issueIds;

  const IssueClusterModel({
    required this.clusterId,
    required this.title,
    required this.primaryCategory,
    required this.locationPattern,
    required this.incidentCount,
    required this.urgency,
    required this.issueIds,
  });
}

class CampusAnalyticsModel {
  final int totalIssues;
  final int resolvedIssues;
  final int criticalIssues;
  final double resolutionRate;
  final double averageResolutionHours;
  final double lostFoundRecoveryRate;
  final int campusReliabilityScore;
  final Map<String, int> categoryDistribution;
  final List<IssueClusterModel> problemClusters;

  const CampusAnalyticsModel({
    required this.totalIssues,
    required this.resolvedIssues,
    required this.criticalIssues,
    required this.resolutionRate,
    required this.averageResolutionHours,
    required this.lostFoundRecoveryRate,
    required this.campusReliabilityScore,
    required this.categoryDistribution,
    required this.problemClusters,
  });
}
