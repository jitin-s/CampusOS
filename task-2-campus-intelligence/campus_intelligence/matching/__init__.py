"""Smart Lost & Found Matching Subsystem."""

from campus_intelligence.matching.service import MatchingService
from campus_intelligence.matching.rules import (
    MatchWeights,
    evaluate_category,
    evaluate_brand,
    evaluate_color,
    evaluate_location,
    evaluate_time_proximity,
    evaluate_name_and_description,
    evaluate_category_detailed,
    evaluate_item_type_detailed,
    evaluate_brand_detailed,
    evaluate_color_detailed,
    evaluate_location_detailed,
    evaluate_time_proximity_detailed,
    evaluate_description_detailed,
)
from campus_intelligence.matching.demo_data import (
    get_demo_lost_items,
    get_demo_found_items,
    get_demo_dataset,
)

__all__ = [
    "MatchingService",
    "MatchWeights",
    "evaluate_category",
    "evaluate_brand",
    "evaluate_color",
    "evaluate_location",
    "evaluate_time_proximity",
    "evaluate_name_and_description",
    "evaluate_category_detailed",
    "evaluate_item_type_detailed",
    "evaluate_brand_detailed",
    "evaluate_color_detailed",
    "evaluate_location_detailed",
    "evaluate_time_proximity_detailed",
    "evaluate_description_detailed",
    "get_demo_lost_items",
    "get_demo_found_items",
    "get_demo_dataset",
]
