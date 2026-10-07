"""Unit tests for AnalyticsService."""

import unittest
from campus_intelligence.analytics.service import AnalyticsService
from campus_intelligence.core.models import IssueRecord, LostItem, FoundItem


class TestAnalyticsService(unittest.TestCase):
    def setUp(self):
        self.service = AnalyticsService()

    def test_empty_dataset_zero_division_safety(self):
        """Empty lists must yield clean baseline figures without division by zero errors."""
        analytics = self.service.calculate_campus_analytics([], [], [])
        self.assertEqual(analytics.total_issues, 0)
        self.assertEqual(analytics.active_issues, 0)
        self.assertEqual(analytics.resolved_issues, 0)
        self.assertEqual(analytics.average_resolution_time_hours, 0.0)
        self.assertEqual(analytics.lost_found_recovery_rate, 0.0)
        self.assertGreaterEqual(analytics.campus_reliability_score, 0.0)

    def test_sample_operational_dataset(self):
        """Calculate metrics against a representative set of issues and items."""
        issues = [
            IssueRecord(
                id="i1",
                title="Broken desk",
                description="Desk broken",
                category="classroom",
                location="Room 101",
                status="resolved",
                department="Estate & Civil",
                created_at="2026-10-06T08:00:00",
                resolved_at="2026-10-06T14:00:00",  # 6 hours
            ),
            IssueRecord(
                id="i2",
                title="Wi-Fi slow",
                description="Wi-Fi slow",
                category="wifi",
                location="Library",
                status="in_progress",
                department="IT",
                created_at="2026-10-07T09:00:00",
            ),
            IssueRecord(
                id="i3",
                title="Tube light out",
                description="Tube light out",
                category="electrical",
                location="Room 101",
                status="closed",
                department="Electrical Maintenance",
                created_at="2026-10-06T10:00:00",
                resolved_at="2026-10-06T12:00:00",  # 2 hours
            ),
        ]

        lost_items = [
            LostItem(id="l1", item_name="Watch", category="Personal", metadata={"status": "recovered"}),
            LostItem(id="l2", item_name="Umbrella", category="Personal", metadata={"status": "open"}),
        ]
        found_items = [
            FoundItem(id="f1", item_name="Watch", category="Personal"),
        ]

        analytics = self.service.calculate_campus_analytics(issues, lost_items, found_items)

        self.assertEqual(analytics.total_issues, 3)
        self.assertEqual(analytics.active_issues, 1)
        self.assertEqual(analytics.resolved_issues, 2)
        self.assertAlmostEqual(analytics.resolution_rate, 66.7, places=1)
        # Average of 6h and 2h = 4h
        self.assertEqual(analytics.average_resolution_time_hours, 4.0)
        # 1 recovered out of 2 = 50%
        self.assertEqual(analytics.lost_found_recovery_rate, 50.0)
        self.assertIn("classroom", analytics.category_distribution)
        self.assertIn("Room 101", analytics.location_distribution)
        self.assertGreaterEqual(analytics.campus_reliability_score, 50.0)


if __name__ == "__main__":
    unittest.main()
