"""CampusOS Intelligence Engine - Abstract Service Interfaces.

Formal contracts adhering to SOLID principles:
- Interface Segregation (focused, independent interfaces)
- Dependency Inversion (clients depend on abstractions, not concrete implementations)
"""

from abc import ABC, abstractmethod
from typing import List, Dict, Any, Optional
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


class IMatchingService(ABC):
    """Interface for Lost & Found item matching."""

    @abstractmethod
    def calculate_match(
        self,
        lost_item: LostItem,
        found_item: FoundItem,
        threshold: int = 50,
    ) -> MatchResult:
        """Calculate deterministic similarity between a lost item and a found item."""
        pass

    @abstractmethod
    def find_matches_for_lost(
        self,
        lost_item: LostItem,
        found_items: List[FoundItem],
        threshold: int = 50,
        limit: int = 10,
    ) -> List[MatchResult]:
        """Find matching found items for a given lost item, ranked by score descending."""
        pass


class IClassificationService(ABC):
    """Interface for issue classification and department routing."""

    @abstractmethod
    def classify_issue(
        self,
        title: str,
        description: str,
        location: str,
    ) -> ClassificationResult:
        """Classify an issue into category, subcategory, and responsible department."""
        pass


class IPriorityService(ABC):
    """Interface for calculating issue priority scores."""

    @abstractmethod
    def calculate_priority(
        self,
        category: str,
        severity: str,
        location: str,
        affected_users: int = 1,
        urgency: str = "medium",
        recurrence_count: int = 1,
    ) -> PriorityResult:
        """Calculate explainable priority level and numerical score."""
        pass


class IClusteringService(ABC):
    """Interface for detecting recurring and localized problem clusters."""

    @abstractmethod
    def cluster_issues(
        self,
        issues: List[IssueRecord],
        time_window_hours: int = 72,
        similarity_threshold: float = 0.5,
    ) -> List[IssueCluster]:
        """Group co-located or recurring issues into clusters."""
        pass


class IAnalyticsService(ABC):
    """Interface for campus operational analytics and reliability scoring."""

    @abstractmethod
    def calculate_campus_analytics(
        self,
        issues: List[IssueRecord],
        lost_items: List[LostItem],
        found_items: List[FoundItem],
        clusters: Optional[List[IssueCluster]] = None,
    ) -> CampusAnalytics:
        """Calculate high-level campus operational metrics."""
        pass
