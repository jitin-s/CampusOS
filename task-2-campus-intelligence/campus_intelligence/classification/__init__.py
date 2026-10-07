"""Issue Classification Subsystem."""

from campus_intelligence.classification.service import ClassificationService
from campus_intelligence.classification.rules import TAXONOMY, extract_location_context

__all__ = [
    "ClassificationService",
    "TAXONOMY",
    "extract_location_context",
]
