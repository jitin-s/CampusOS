"""Lost & Found Matching Subsystem."""

from campus_intelligence.matching.service import MatchingService
from campus_intelligence.matching.rules import (
    evaluate_category,
    evaluate_brand,
    evaluate_color,
    evaluate_location,
    evaluate_time_proximity,
    evaluate_name_and_description,
)

__all__ = [
    "MatchingService",
    "evaluate_category",
    "evaluate_brand",
    "evaluate_color",
    "evaluate_location",
    "evaluate_time_proximity",
    "evaluate_name_and_description",
]
