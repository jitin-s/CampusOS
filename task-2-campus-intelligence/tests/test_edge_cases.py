"""Unit tests for edge cases and boundary conditions."""

import unittest
from campus_intelligence.matching.service import MatchingService
from campus_intelligence.classification.service import ClassificationService
from campus_intelligence.priority.service import PriorityService
from campus_intelligence.clustering.service import ClusteringService
from campus_intelligence.analytics.service import AnalyticsService
from campus_intelligence.core.models import LostItem, FoundItem, IssueRecord


class TestEdgeCases(unittest.TestCase):
    def test_matching_malformed_timestamps(self):
        """Service should tolerate completely invalid timestamp formats without raising errors."""
        service = MatchingService()
        lost = LostItem(
            id="l1",
            item_name="Phone",
            category="Electronics",
            occurred_at="invalid-date-string-xyz",
        )
        found = FoundItem(
            id="f1",
            item_name="Phone",
            category="Electronics",
            occurred_at="not-a-timestamp",
        )

        res = service.calculate_match(lost, found)
        self.assertIsInstance(res.score, int)
        self.assertNotIn("time_proximity", res.factors)

    def test_classification_emojis_and_special_characters(self):
        """Text containing emojis, punctuation, and unicode symbols should be handled cleanly."""
        service = ClassificationService()
        res = service.classify_issue(
            title="⚠️ Projector broken in B204!! 🚨",
            description="HDMI cord is completely broken ⚡⚡ and projector won't light up!???",
            location="B204",
        )
        self.assertEqual(res.category, "equipment")
        self.assertEqual(res.department, "IT")

    def test_priority_non_numeric_and_negative_affected_users(self):
        """Malformed or negative affected_users should be normalized gracefully."""
        service = PriorityService()
        # Invalid string for affected_users
        res1 = service.calculate_priority(
            category="wifi",
            severity="medium",
            location="Cafeteria",
            affected_users="invalid_str",  # type: ignore
        )
        self.assertIsInstance(res1.score, int)

        # Negative number
        res2 = service.calculate_priority(
            category="wifi",
            severity="medium",
            location="Cafeteria",
            affected_users=-50,
        )
        self.assertIsInstance(res2.score, int)
        self.assertGreaterEqual(res2.score, 0)

    def test_clustering_with_empty_or_single_issue(self):
        """Clustering with 0 or 1 issue should return empty list of clusters."""
        service = ClusteringService()
        self.assertEqual(service.cluster_issues([]), [])

        single = [IssueRecord(id="1", title="Leak", description="Leak", category="water", location="Lab")]
        self.assertEqual(service.cluster_issues(single), [])

    def test_analytics_with_negative_or_inverted_timestamps(self):
        """Issues where resolved_at is before created_at should not produce negative duration."""
        service = AnalyticsService()
        issue = IssueRecord(
            id="bad-time",
            title="Glitch",
            description="Glitch",
            category="other",
            location="Office",
            status="resolved",
            created_at="2026-10-07T12:00:00",
            resolved_at="2026-10-07T10:00:00",  # earlier than created!
        )
        analytics = service.calculate_campus_analytics([issue], [], [])
        self.assertEqual(analytics.average_resolution_time_hours, 0.0)


if __name__ == "__main__":
    unittest.main()
