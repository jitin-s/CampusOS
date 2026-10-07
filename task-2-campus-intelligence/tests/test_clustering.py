"""Unit tests for ClusteringService."""

import unittest
from campus_intelligence.clustering.service import ClusteringService
from campus_intelligence.core.models import IssueRecord


class TestClusteringService(unittest.TestCase):
    def setUp(self):
        self.service = ClusteringService()

    def test_recurring_projector_failures_cluster(self):
        """Test PRD scenario: Multiple projector failures in B204 detected as a recurring cluster."""
        issues = [
            IssueRecord(
                id="iss-1",
                title="Projector in room B204 not turning on",
                description="Power light is blinking red",
                category="equipment",
                location="Room B204",
                severity="high",
                created_at="2026-10-05T09:00:00",
            ),
            IssueRecord(
                id="iss-2",
                title="Projector flickering in B204",
                description="Display turns off every few minutes during class",
                category="equipment",
                location="Room B204",
                severity="medium",
                created_at="2026-10-05T14:30:00",
            ),
            IssueRecord(
                id="iss-3",
                title="Overhead projector died again in B 204",
                description="Completely unresponsive",
                category="equipment",
                location="Room B204",
                severity="high",
                created_at="2026-10-06T10:00:00",
            ),
        ]

        clusters = self.service.cluster_issues(issues, time_window_hours=72)

        self.assertEqual(len(clusters), 1)
        cluster = clusters[0]
        self.assertEqual(cluster.issue_count, 3)
        self.assertTrue(cluster.is_recurring)
        self.assertIn("Projector", cluster.topic)
        self.assertEqual(set(cluster.issue_ids), {"iss-1", "iss-2", "iss-3"})

    def test_wifi_outage_clustering(self):
        """Test grouping 'Wi-Fi down', 'no internet', 'network unavailable' in Library."""
        issues = [
            IssueRecord(
                id="wifi-1",
                title="Wi-Fi down in Central Library",
                description="Cannot connect to student wifi network",
                category="wifi",
                location="Central Library",
                created_at="2026-10-07T08:00:00",
            ),
            IssueRecord(
                id="wifi-2",
                title="No internet connection in Library reading room",
                description="All laptops disconnected",
                category="wifi",
                location="Central Library",
                created_at="2026-10-07T08:20:00",
            ),
        ]

        clusters = self.service.cluster_issues(issues, time_window_hours=24)
        self.assertEqual(len(clusters), 1)
        self.assertEqual(clusters[0].issue_count, 2)
        self.assertIn("wifi-1", clusters[0].issue_ids)
        self.assertIn("wifi-2", clusters[0].issue_ids)

    def test_unrelated_issues_do_not_cluster(self):
        """Distinct issues in different locations should not be grouped."""
        issues = [
            IssueRecord(
                id="diff-1",
                title="Broken chair",
                description="Chair leg snapped",
                category="classroom",
                location="Block C Room 101",
            ),
            IssueRecord(
                id="diff-2",
                title="Water tap leaking",
                description="Water dripping in hostel bathroom",
                category="water",
                location="Hostel Block 4",
            ),
        ]

        clusters = self.service.cluster_issues(issues)
        self.assertEqual(len(clusters), 0)


if __name__ == "__main__":
    unittest.main()
