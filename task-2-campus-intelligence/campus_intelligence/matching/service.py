"""CampusOS Smart Lost & Found Matching Engine.

Authoritative implementation for TASK-2 / PHASE-2: SMART LOST & FOUND MATCHING.
Implements IMatchingService with deterministic scoring, configurable weights,
factor explanations, conflict detection, and recommendation ratings.

Conforms to SOLID:
- Single Responsibility: calculates match similarity between lost and found items.
- Open/Closed: scoring weights and attribute evaluators are fully configurable.
- Dependency Inversion: adheres to IMatchingService abstraction with zero DB/UI dependencies.
"""

from typing import List, Dict, Any, Union, Optional
from campus_intelligence.core.interfaces import IMatchingService
from campus_intelligence.core.models import LostItem, FoundItem, MatchResult
from campus_intelligence.core.types import MatchConfidence
from campus_intelligence.matching.rules import (
    MatchWeights,
    evaluate_category_detailed,
    evaluate_item_type_detailed,
    evaluate_brand_detailed,
    evaluate_color_detailed,
    evaluate_location_detailed,
    evaluate_time_proximity_detailed,
    evaluate_description_detailed,
)


class MatchingService(IMatchingService):
    """Deterministic, explainable Smart Lost & Found matching engine."""

    def __init__(self, default_weights: Optional[MatchWeights] = None):
        """Initialize MatchingService with optional custom MatchWeights."""
        self.default_weights = default_weights or MatchWeights()

    def calculate_match(
        self,
        lost_item: Union[LostItem, Dict[str, Any]],
        found_item: Union[FoundItem, Dict[str, Any]],
        threshold: int = 50,
        weights: Optional[MatchWeights] = None,
    ) -> MatchResult:
        """Calculate explainable similarity score between a lost and found item.

        Args:
            lost_item: LostItem instance or dictionary.
            found_item: FoundItem instance or dictionary.
            threshold: Minimum score (0-100) to consider a valid match.
            weights: Optional custom MatchWeights overriding defaults.

        Returns:
            MatchResult containing score, confidence, recommendation, factor_scores,
            matching_factors, and human_readable_explanation.
        """
        w = weights or self.default_weights

        # Normalize to DTO dataclasses
        lost = LostItem.from_dict(lost_item) if isinstance(lost_item, dict) else lost_item
        found = FoundItem.from_dict(found_item) if isinstance(found_item, dict) else found_item

        matching_factors: List[str] = []
        factor_scores: Dict[str, float] = {}
        human_explanation: List[str] = []

        # 1. Category Evaluation
        cat_score, cat_matched, cat_factor, cat_exp = evaluate_category_detailed(
            lost.category, found.category, weight=w.category
        )
        factor_scores["category"] = cat_score
        human_explanation.append(cat_exp)
        if cat_matched and cat_factor:
            matching_factors.append(cat_factor)

        # 2. Item Type Evaluation
        type_a = lost.item_type or lost.item_name
        type_b = found.item_type or found.item_name
        type_score, type_matched, type_factor, type_exp = evaluate_item_type_detailed(
            type_a, type_b, weight=w.item_type
        )
        factor_scores["item_type"] = type_score
        human_explanation.append(type_exp)
        if type_matched and type_factor:
            matching_factors.append(type_factor)

        # 3. Brand Evaluation
        brand_score, brand_matched, brand_factor, brand_exp = evaluate_brand_detailed(
            lost.brand, found.brand, weight=w.brand
        )
        factor_scores["brand"] = brand_score
        human_explanation.append(brand_exp)
        if brand_matched and brand_factor:
            matching_factors.append(brand_factor)

        # 4. Color Evaluation
        color_score, color_matched, color_factor, color_exp = evaluate_color_detailed(
            lost.color, found.color, weight=w.color
        )
        factor_scores["color"] = color_score
        human_explanation.append(color_exp)
        if color_matched and color_factor:
            matching_factors.append(color_factor)

        # 5. Location Proximity
        loc_score, loc_matched, loc_factor, loc_exp = evaluate_location_detailed(
            lost.location, found.location, weight=w.location
        )
        factor_scores["location"] = loc_score
        human_explanation.append(loc_exp)
        if loc_matched and loc_factor:
            matching_factors.append(loc_factor)

        # 6. Time Proximity
        time_score, time_matched, time_factor, time_exp = evaluate_time_proximity_detailed(
            lost.occurred_at, found.occurred_at, weight=w.time
        )
        factor_scores["time"] = time_score
        human_explanation.append(time_exp)
        if time_matched and time_factor:
            matching_factors.append(time_factor)

        # 7. Description Details
        desc_score, desc_matched, desc_factor, desc_exp = evaluate_description_detailed(
            lost.description, found.description, weight=w.description
        )
        factor_scores["description"] = desc_score
        human_explanation.append(desc_exp)
        if desc_matched and desc_factor:
            matching_factors.append(desc_factor)

        # Raw total score
        raw_total = sum(factor_scores.values())

        # Conflict Penalty / Hard Boundary Guards:
        # If both category and item type completely conflict (e.g. umbrella vs laptop), clamp max score
        has_cat_conflict = (not cat_matched) and bool(lost.category) and bool(found.category)
        has_type_conflict = (not type_matched) and bool(type_a) and bool(type_b)
        has_brand_conflict = (
            bool(lost.brand) and bool(found.brand) and (not brand_matched)
        )

        if has_cat_conflict and has_type_conflict:
            raw_total = min(raw_total, 15.0)

        # If brands explicitly conflict on branded items, penalize
        if has_brand_conflict and (brand_score == 0.0):
            raw_total = max(0.0, raw_total - 15.0)

        final_score = int(min(100, max(0, round(raw_total))))

        # Determine Recommendation
        if final_score >= 80 and not has_cat_conflict and not has_brand_conflict:
            recommendation = "STRONG MATCH"
        elif final_score >= 60 and not has_cat_conflict:
            recommendation = "POTENTIAL MATCH"
        elif final_score >= 40:
            recommendation = "POSSIBLE MATCH"
        elif final_score >= 20:
            recommendation = "WEAK MATCH"
        else:
            recommendation = "NO MATCH"

        # Determine Confidence
        if final_score >= 85 and not has_brand_conflict:
            confidence = MatchConfidence.VERY_HIGH.value
        elif final_score >= 70 and not has_brand_conflict:
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
            recommendation=recommendation,
            factors=matching_factors,
            breakdown=factor_scores,
            is_match=is_match,
            factor_scores=factor_scores,
            matching_factors=matching_factors,
            human_readable_explanation=human_explanation,
            lost_item_id=lost.id,
            found_item_id=found.id,
        )

    def find_matches_for_lost(
        self,
        lost_item: Union[LostItem, Dict[str, Any]],
        found_items: List[Union[FoundItem, Dict[str, Any]]],
        threshold: int = 50,
        limit: int = 10,
        weights: Optional[MatchWeights] = None,
    ) -> List[MatchResult]:
        """Rank and return matches above threshold for a given lost item."""
        results: List[MatchResult] = []
        for found in found_items:
            res = self.calculate_match(lost_item, found, threshold=threshold, weights=weights)
            if res.is_match:
                results.append(res)

        # Sort descending by score
        results.sort(key=lambda r: r.score, reverse=True)
        return results[:limit]

    @staticmethod
    def format_explanation_report(result: MatchResult) -> str:
        """Format a human-readable text summary of the match result.

        Example:
            94% — HIGH CONFIDENCE

            ✓ Category matches (Electronics)
            ✓ Brand matches (Casio)
            ✓ Color matches (Black)
            ✓ Location is nearby (Central Library)
            ✓ Time is similar (Within 24 hours)

            Recommendation:
            STRONG MATCH
        """
        confidence_display = result.confidence.replace("_", " ").upper() + " CONFIDENCE"
        lines = [
            f"{result.score}% — {confidence_display}",
            "",
        ]
        for exp in result.human_readable_explanation:
            lines.append(exp)

        lines.extend([
            "",
            "Recommendation:",
            result.recommendation,
        ])
        return "\n".join(lines)
