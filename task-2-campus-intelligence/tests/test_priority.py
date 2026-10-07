"""Unit tests for PriorityService."""

import unittest
from campus_intelligence.priority.service import PriorityService
from campus_intelligence.core.types import PriorityLevel


class TestPriorityService(unittest.TestCase):
    def setUp(self):
        self.service = PriorityService()

    def test_critical_infrastructure_emergency(self):
        """Power / server room failure with high urgency should evaluate to CRITICAL."""
        res = self.service.calculate_priority(
            category="electrical",
            severity="critical",
            location="Campus Data Center / Server Room",
            affected_users=200,
            urgency="immediate",
            recurrence_count=1,
        )

        self.assertEqual(res.priority, PriorityLevel.CRITICAL.value)
        self.assertGreaterEqual(res.score, 75)
        self.assertTrue(any("Critical" in exp for exp in res.explanation))
        self.assertTrue(any("affected users" in exp for exp in res.explanation))

    def test_classroom_projector_exam_high_priority(self):
        """Classroom projector failure affecting 60 students should score HIGH."""
        res = self.service.calculate_priority(
            category="equipment",
            severity="high",
            location="Room B204 Classroom",
            affected_users=60,
            urgency="today",
            recurrence_count=1,
        )

        self.assertEqual(res.priority, PriorityLevel.HIGH.value)
        self.assertGreaterEqual(res.score, 55)

    def test_low_priority_individual_request(self):
        """Low severity issue affecting 1 user in common area should score LOW."""
        res = self.service.calculate_priority(
            category="classroom",
            severity="low",
            location="Outer Lawn Bench",
            affected_users=1,
            urgency="low",
            recurrence_count=1,
        )

        self.assertEqual(res.priority, PriorityLevel.LOW.value)
        self.assertLess(res.score, 35)

    def test_recurrence_boost(self):
        """Repeated failures should increase the priority score."""
        res_first = self.service.calculate_priority(
            category="wifi",
            severity="medium",
            location="Library 2nd Floor",
            affected_users=10,
            urgency="medium",
            recurrence_count=1,
        )
        res_third = self.service.calculate_priority(
            category="wifi",
            severity="medium",
            location="Library 2nd Floor",
            affected_users=10,
            urgency="medium",
            recurrence_count=3,
        )

        self.assertGreater(res_third.score, res_first.score)
        self.assertEqual(res_third.breakdown.get("recurrence"), 10)
        self.assertTrue(any("recurrence" in exp.lower() for exp in res_third.explanation))

    def test_score_clamping(self):
        """Scores must strictly remain within [0, 100]."""
        res_max = self.service.calculate_priority(
            category="electrical",
            severity="critical",
            location="Exam Hall",
            affected_users=500,
            urgency="immediate",
            recurrence_count=5,
        )
        self.assertLessEqual(res_max.score, 100)
        self.assertGreaterEqual(res_max.score, 0)


if __name__ == "__main__":
    unittest.main()
