"""Unit tests for ClassificationService."""

import unittest
from campus_intelligence.classification.service import ClassificationService
from campus_intelligence.core.types import IssueCategory, CampusDepartment


class TestClassificationService(unittest.TestCase):
    def setUp(self):
        self.service = ClassificationService()

    def test_projector_issue_classification(self):
        """Test canonical PRD example: 'Projector not working in B204' -> Equipment, Projector, IT."""
        res = self.service.classify_issue(
            title="Projector not working in B204",
            description="The overhead projector in room B204 will not turn on and the HDMI cable is loose.",
            location="Room B204",
        )

        self.assertEqual(res.category, IssueCategory.EQUIPMENT.value)
        self.assertEqual(res.subcategory, "projector")
        self.assertEqual(res.department, CampusDepartment.IT.value)
        self.assertGreaterEqual(res.confidence, 0.5)
        self.assertIn("projector", [k.lower() for k in res.matched_keywords])

    def test_wifi_outage_classification(self):
        """Test Wi-Fi connectivity issue classification."""
        res = self.service.classify_issue(
            title="Wi-Fi down in Library 3rd Floor",
            description="No internet connection available on the student network, router lights are red.",
            location="Library 3rd Floor",
        )

        self.assertEqual(res.category, IssueCategory.WIFI.value)
        self.assertEqual(res.department, CampusDepartment.IT.value)
        self.assertGreaterEqual(res.confidence, 0.6)

    def test_water_leakage_classification(self):
        """Test plumbing / water leak classification."""
        res = self.service.classify_issue(
            title="Water leaking from tap in washroom",
            description="The faucet on the 2nd floor sink is broken and overflowing onto the floor.",
            location="Block A 2nd Floor Washroom",
        )

        self.assertEqual(res.category, IssueCategory.WATER.value)
        self.assertEqual(res.department, CampusDepartment.ESTATE.value)

    def test_electrical_lighting_classification(self):
        """Test lighting / power classification."""
        res = self.service.classify_issue(
            title="Tube light flickering in Lecture Hall 1",
            description="The main ceiling bulb is constantly blinking and making buzzing noises.",
            location="Lecture Hall 1",
        )

        self.assertEqual(res.category, IssueCategory.ELECTRICAL.value)
        self.assertEqual(res.department, CampusDepartment.ELECTRICAL.value)

    def test_cleanliness_sanitation_classification(self):
        """Test housekeeping / dustbin overflow issue."""
        res = self.service.classify_issue(
            title="Dustbin overflowing with garbage near cafeteria",
            description="Trash has not been cleared for two days and there is bad odor.",
            location="Cafeteria Corridor",
        )

        self.assertEqual(res.category, IssueCategory.CLEANLINESS.value)
        self.assertEqual(res.department, CampusDepartment.SANITATION.value)

    def test_unrecognized_issue_fallback(self):
        """Unrecognized description should gracefully default without crashing."""
        res = self.service.classify_issue(
            title="Random vague statement",
            description="Something unclear happened somewhere",
            location="Corridor",
        )

        self.assertEqual(res.category, IssueCategory.OTHER.value)
        self.assertEqual(res.department, CampusDepartment.GENERAL.value)
        self.assertLessEqual(res.confidence, 0.5)


if __name__ == "__main__":
    unittest.main()
