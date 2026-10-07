"""CampusOS Intelligence Engine.

Independent, explainable, and deterministic intelligence services for CampusOS:
- MatchingService: Lost & Found smart matching
- ClassificationService: Issue category and department routing
- PriorityService: Explainable priority scoring
- ClusteringService: Problem clustering and hotspot detection
- AnalyticsService: Campus reliability and operational KPIs
"""

from campus_intelligence.core.types import (
    PriorityLevel,
    MatchConfidence,
    IssueCategory,
    CampusDepartment,
    IssueStatus,
)
from campus_intelligence.core.models import (
    LostItem,
    FoundItem,
    MatchResult,
    ClassificationResult,
    PriorityResult,
    IssueRecord,
    IssueCluster,
    CampusAnalytics,
)
from campus_intelligence.core.interfaces import (
    IMatchingService,
    IClassificationService,
    IPriorityService,
    IClusteringService,
    IAnalyticsService,
)
from campus_intelligence.matching.rules import MatchWeights
from campus_intelligence.matching.service import MatchingService
from campus_intelligence.classification.service import ClassificationService
from campus_intelligence.priority.service import PriorityService
from campus_intelligence.clustering.service import ClusteringService
from campus_intelligence.analytics.service import AnalyticsService

__all__ = [
    # Types
    "PriorityLevel",
    "MatchConfidence",
    "IssueCategory",
    "CampusDepartment",
    "IssueStatus",
    "MatchWeights",
    # Models
    "LostItem",
    "FoundItem",
    "MatchResult",
    "ClassificationResult",
    "PriorityResult",
    "IssueRecord",
    "IssueCluster",
    "CampusAnalytics",
    # Interfaces
    "IMatchingService",
    "IClassificationService",
    "IPriorityService",
    "IClusteringService",
    "IAnalyticsService",
    # Implementations
    "MatchingService",
    "ClassificationService",
    "PriorityService",
    "ClusteringService",
    "AnalyticsService",
]
