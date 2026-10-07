"""CampusOS Lost & Found Matching Service.

Implements IMatchingService with explainable, deterministic scoring.
Follows SOLID principles:
- Single Responsibility: calculates match similarity between lost and found items.
- Dependency Inversion: conforms to IMatchingService abstraction.
"""

from typing import List, Dict, Any, Union
from campus_intelligence.core.interfaces import IMatchingService
from campus_intelligence.core.models import LostItem, FoundItem, MatchResult
from campus_intelligence.core.types import MatchConfidence
from campus_intelligence.matching.rules import (
    evaluate_category,
    evaluate_brand,
    evaluate_color,
    evaluate_location,
    evaluate_time_proximity,
    evaluate_name_and_description,
)


class MatchingService(IMatchingService):
    """Deterministic, explainable Lost & Found matching engine."""

    def calculate_match(
        self,
        lost_item: Union[LostItem, Dict[str, Any]],
        found_item: Union[FoundItem, Dict[str, Any]],
        threshold: int = 50,
    ) -> MatchResult:
        """Calculate explainable similarity score between a lost and found item.

        Args:
            lost_item: LostItem instance or dictionary.
            found_item: FoundItem instance or dictionary.
            threshold: Minimum score (0-100) to consider a valid match.

        Returns:
            MatchResult containing score, confidence, factors list, and detailed breakdown.
        """
        # Normalize to dataclasses if dictionaries provided
        lost = LostItem.from_dict(lost_item) if isinstance(lost_item, dict) else lost_item
        found = FoundItem.from_dict(found_item) if isinstance(found_item, dict) else found_item

        factors: List[str] = []
        breakdown: Dict[str, float] = {}

        # 1. Category Evaluation
        cat_score, cat_matched = evaluate_category(lost.category, found.category)
        breakdown["category"] = cat_score
        if cat_matched:
            factors.append("category_match")

        # 2. Brand Evaluation
        brand_score, brand_matched = evaluate_brand(lost.brand, found.brand)
        breakdown["brand"] = brand_score
        if brand_matched:
            factors.append("brand_match")

        # 3. Color Evaluation
        color_score, color_matched = evaluate_color(lost.color, found.color)
        breakdown["color"] = color_score
        if color_matched:
            factors.append("color_match")

        # 4. Location Proximity
        loc_score, loc_matched = evaluate_location(lost.location, found.location)
        breakdown["location"] = loc_score
        if loc_matched:
            factors.append("location_proximity")

        # 5. Time Proximity
        time_score, time_matched = evaluate_time_proximity(lost.occurred_at, found.occurred_at)
        breakdown["time"] = time_score
        if time_matched:
            factors.append("time_proximity")

        # 6. Name and Description Similarity
        text_score, text_matched = evaluate_name_and_description(
            lost.item_name,
            lost.description,
            found.item_name,
            found.description,
        )
        breakdown["description_similarity"] = text_score
        if text_matched:
            factors.append("description_similarity")

        raw_total = sum(breakdown.values())
        final_score = int(min(100, max(0, round(raw_total))))

        # Determine confidence level
        if final_score >= 85:
            confidence = MatchConfidence.VERY_HIGH.value
        elif final_score >= 70:
            confidence = MatchConfidence.HIGH.value
        elif final_score >= 50:
            confidence = MatchConfidence.MEDIUM.value
        elif final_score >= 25:
            confidence = MatchConfidence.LOW.value
        else:
            confidence = MatchConfidence.NONE.value

        is_match = final_score >= threshold

        return MatchResult(
            score=final_score,
            confidence=confidence,
            factors=factors,
            breakdown=breakdown,
            is_match=is_match,
            lost_item_id=lost.id,
            found_item_id=found.id,
        )

    def find_matches_for_lost(
        self,
        lost_item: Union[LostItem, Dict[str, Any]],
        found_items: List[Union[FoundItem, Dict[str, Any]]],
        threshold: int = 50,
        limit: int = 10,
    ) -> List[MatchResult]:
        """Rank and return matches above threshold for a given lost item."""
        results: List[MatchResult] = []
        for found in found_items:
            res = self.calculate_match(lost_item, found, threshold=threshold)
            if res.is_match:
                results.append(res)

        # Sort descending by score
        results.sort(key=lambda r: r.score, reverse=True)
        return results[:limit]
