"""Problem Clustering Subsystem."""

from campus_intelligence.clustering.service import ClusteringService
from campus_intelligence.clustering.detector import (
    normalize_location_key,
    are_locations_compatible,
    are_issues_similar,
    build_cluster_topic,
)

__all__ = [
    "ClusteringService",
    "normalize_location_key",
    "are_locations_compatible",
    "are_issues_similar",
    "build_cluster_topic",
]
