"""CampusOS Intelligence Engine - Data Transfer Objects (DTOs) and Models.

Pure Python dataclasses with serialization support for clean cross-layer boundary exchange.
"""

from dataclasses import dataclass, field, asdict
from datetime import datetime
from typing import List, Dict, Any, Optional
from campus_intelligence.core.types import PriorityLevel, MatchConfidence, IssueCategory


@dataclass
class LostItem:
    """Represents a reported lost item."""
    id: str
    item_name: str
    category: str
    campus_id: str = "main-campus"
    brand: Optional[str] = None
    color: Optional[str] = None
    location: Optional[str] = None
    occurred_at: Optional[str] = None  # ISO timestamp or date string
    description: Optional[str] = None
    metadata: Dict[str, Any] = field(default_factory=dict)

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "LostItem":
        return cls(
            id=str(data.get("id", "")),
            item_name=str(data.get("item_name", "")),
            category=str(data.get("category", "")),
            campus_id=str(data.get("campus_id", "main-campus")),
            brand=data.get("brand"),
            color=data.get("color"),
            location=data.get("location"),
            occurred_at=data.get("occurred_at"),
            description=data.get("description"),
            metadata=data.get("metadata", {}) or {},
        )

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class FoundItem:
    """Represents a reported found item."""
    id: str
    item_name: str
    category: str
    campus_id: str = "main-campus"
    brand: Optional[str] = None
    color: Optional[str] = None
    location: Optional[str] = None
    occurred_at: Optional[str] = None
    description: Optional[str] = None
    metadata: Dict[str, Any] = field(default_factory=dict)

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "FoundItem":
        return cls(
            id=str(data.get("id", "")),
            item_name=str(data.get("item_name", "")),
            category=str(data.get("category", "")),
            campus_id=str(data.get("campus_id", "main-campus")),
            brand=data.get("brand"),
            color=data.get("color"),
            location=data.get("location"),
            occurred_at=data.get("occurred_at"),
            description=data.get("description"),
            metadata=data.get("metadata", {}) or {},
        )

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class MatchResult:
    """Explainable result from Lost & Found matching."""
    score: int  # 0 to 100
    confidence: str  # none, low, medium, high, very_high
    factors: List[str]  # e.g. ["category_match", "brand_match", ...]
    breakdown: Dict[str, float]  # factor -> points awarded
    is_match: bool  # whether threshold is met
    lost_item_id: Optional[str] = None
    found_item_id: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class ClassificationResult:
    """Result of classifying an issue description."""
    category: str
    subcategory: str
    department: str
    confidence: float
    matched_keywords: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class PriorityResult:
    """Transparent priority score calculation."""
    priority: str  # LOW, MEDIUM, HIGH, CRITICAL
    score: int  # 0 to 100
    explanation: List[str]
    breakdown: Dict[str, int] = field(default_factory=dict)

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class IssueRecord:
    """Representation of an issue for clustering and analytics."""
    id: str
    title: str
    description: str
    category: str
    location: str
    subcategory: Optional[str] = None
    severity: str = "medium"
    priority: str = "MEDIUM"
    status: str = "reported"
    department: Optional[str] = None
    created_at: Optional[str] = None
    resolved_at: Optional[str] = None

    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> "IssueRecord":
        return cls(
            id=str(data.get("id", "")),
            title=str(data.get("title", "")),
            description=str(data.get("description", "")),
            category=str(data.get("category", "other")),
            location=str(data.get("location", "")),
            subcategory=data.get("subcategory") or data.get("type"),
            severity=str(data.get("severity", "medium")),
            priority=str(data.get("priority", "MEDIUM")),
            status=str(data.get("status", "reported")),
            department=data.get("department"),
            created_at=data.get("created_at"),
            resolved_at=data.get("resolved_at"),
        )

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class IssueCluster:
    """A cluster of related or recurring issues."""
    cluster_id: str
    topic: str
    location: str
    primary_category: str
    issue_count: int
    issue_ids: List[str]
    is_recurring: bool
    severity_level: str
    earliest_issue_at: Optional[str] = None
    latest_issue_at: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class CampusAnalytics:
    """Aggregated campus operational intelligence metrics."""
    total_issues: int
    active_issues: int
    resolved_issues: int
    resolution_rate: float
    average_resolution_time_hours: float
    lost_found_recovery_rate: float
    category_distribution: Dict[str, int]
    location_distribution: Dict[str, int]
    department_performance: Dict[str, Dict[str, Any]]
    recurring_clusters_count: int
    campus_reliability_score: float

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)
