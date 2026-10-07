"""CampusOS Issue Classification Service.

Implements IClassificationService with explainable keyword and taxonomy matching.
Routes issues to appropriate categories, subcategories, and responsible campus departments.
"""

import re
from typing import List, Dict, Any, Tuple
from campus_intelligence.core.interfaces import IClassificationService
from campus_intelligence.core.models import ClassificationResult
from campus_intelligence.core.types import IssueCategory, CampusDepartment
from campus_intelligence.classification.rules import TAXONOMY, extract_location_context


class ClassificationService(IClassificationService):
    """Deterministic, explainable issue classification and routing engine."""

    def __init__(self, custom_taxonomy: List[Dict[str, Any]] = None):
        self._taxonomy = custom_taxonomy or TAXONOMY

    def classify_issue(
        self,
        title: str,
        description: str,
        location: str,
    ) -> ClassificationResult:
        """Classify an issue into category, subcategory, and department.

        Args:
            title: Title or short summary of the issue.
            description: Detailed description of the problem.
            location: Campus location identifier or name (e.g., 'B204', 'Library').

        Returns:
            ClassificationResult with category, subcategory, department, confidence, and matched keywords.
        """
        combined_text = f"{title or ''} {description or ''}".lower()
        cleaned_text = re.sub(r"[^\w\s-]", " ", combined_text)
        words = set(re.findall(r"\b\w+\b", cleaned_text))

        best_entry = None
        best_score = 0.0
        best_matched_keywords: List[str] = []

        loc_context = extract_location_context(location)

        for entry in self._taxonomy:
            entry_keywords = entry["keywords"]
            weight = entry.get("weight", 1.0)

            # Check for keyword matches (both exact words and multi-word phrases)
            matched_here = []
            score = 0.0

            for kw in entry_keywords:
                kw_lower = kw.lower()
                if " " in kw_lower:
                    if kw_lower in combined_text:
                        matched_here.append(kw)
                        score += 2.0 * weight
                else:
                    if kw_lower in words:
                        matched_here.append(kw)
                        score += 1.0 * weight

            # Location context bonus
            if loc_context.get("preferred_category") == entry["category"]:
                score += 0.5

            if score > best_score:
                best_score = score
                best_entry = entry
                best_matched_keywords = matched_here

        # Fallback if no keywords matched
        if not best_entry or best_score <= 0.0:
            category = loc_context.get("preferred_category", IssueCategory.OTHER.value)
            department = loc_context.get("preferred_department", CampusDepartment.GENERAL.value)
            return ClassificationResult(
                category=category,
                subcategory="general_issue",
                department=department,
                confidence=0.2,
                matched_keywords=[],
            )

        # Compute confidence based on match strength
        confidence = min(0.98, max(0.4, 0.4 + (best_score * 0.15)))

        return ClassificationResult(
            category=best_entry["category"],
            subcategory=best_entry["subcategory"],
            department=best_entry["department"],
            confidence=round(confidence, 2),
            matched_keywords=best_matched_keywords,
        )
