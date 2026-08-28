"""
Automated Test Suite for Scoring & Context Engine
"""

import unittest
from Widgets import WIDGETS
from User import parse_user_preferences
from Relevance_matrix import relevance_matrix
from context import calculate_context_score, CONTEXT_EVALUATORS
from Scoring import calculate_personal_score, calculate_final_score, apply_safety_override, rank_widgets


class TestScoringSystem(unittest.TestCase):

    def test_widgets_canonical_list(self):
        """Verify all 8 expected widget categories exist."""
        self.assertEqual(len(WIDGETS), 8)
        self.assertIn("Outdoor Fitness", WIDGETS)
        self.assertIn("Beach & Surf", WIDGETS)
        self.assertIn("Commuter", WIDGETS)

    def test_relevance_matrix_keys(self):
        """Ensure every widget has a row and all interest columns are present."""
        for widget in WIDGETS:
            self.assertIn(widget, relevance_matrix, f"Missing {widget} in relevance_matrix")
            for interest in WIDGETS:
                self.assertIn(interest, relevance_matrix[widget])
                score = relevance_matrix[widget][interest]
                self.assertTrue(0.0 <= score <= 1.0)

    def test_user_preference_parser(self):
        """Test parsing string and float preferences."""
        raw = {
            "Health": "vimp",
            "Outdoor Fitness": "normal",
            "Commuter": 0.8,
            "Events": "not imp"
        }
        parsed = parse_user_preferences(raw)
        self.assertEqual(parsed["Health"], 1.0)
        self.assertEqual(parsed["Outdoor Fitness"], 0.5)
        self.assertEqual(parsed["Commuter"], 0.8)
        self.assertEqual(parsed["Events"], 0.0)

    def test_personal_score_normalization(self):
        """Test personal score bounds and edge cases."""
        # Case 1: All zero preferences
        zero_prefs = {w: 0.0 for w in WIDGETS}
        self.assertEqual(calculate_personal_score("Health", zero_prefs), 0.0)

        # Case 2: Only 1 preference set to 1.0
        health_only = {"Health": 1.0}
        score = calculate_personal_score("Health", health_only)
        self.assertEqual(score, 100.0)  # relevance_matrix['Health']['Health'] == 1.0

        # Case 3: Mixed preferences (Direct 70% + Cross 30%)
        mixed = {"Health": 1.0, "Events": 1.0}
        score = calculate_personal_score("Health", mixed, direct_weight=0.70, cross_weight=0.30)
        # Direct: 100.0 * 0.70 = 70.0
        # Cross: ((1.0*1.0 + 0.3*1.0)/2.0 * 100) * 0.30 = 65.0 * 0.30 = 19.5
        # Total = 89.5
        self.assertAlmostEqual(score, 89.5)

    def test_context_evaluators_bounds_and_missing_keys(self):
        """Verify that any arbitrary/empty context dictionary does not crash and stays in [0, 100]."""
        for widget in WIDGETS:
            # Empty context dictionary
            empty_score = calculate_context_score(widget, {})
            self.assertTrue(0.0 <= empty_score <= 100.0, f"Failed for empty context in {widget}")

            # Extreme weather context
            extreme_ctx = {
                "hour": 3,
                "rain_probability": 100,
                "temperature": -15,
                "uv_index": 14,
                "wind_speed": 75,
                "visibility": 0.5,
                "aqi": 350
            }
            extreme_score = calculate_context_score(widget, extreme_ctx)
            self.assertTrue(0.0 <= extreme_score <= 100.0, f"Failed for extreme context in {widget}")

    def test_outdoor_fitness_logic_fix(self):
        """Verify sunny dry weather scores higher than stormy rain for Outdoor Fitness."""
        dry_sunny = {
            "hour": 7,
            "rain_probability": 5,
            "temperature": 18,
            "uv_index": 2,
            "wind_speed": 8,
            "visibility": 10,
            "outdoor_activity": True
        }
        stormy = {
            "hour": 7,
            "rain_probability": 90,
            "temperature": 18,
            "uv_index": 2,
            "wind_speed": 40,
            "visibility": 2,
            "outdoor_activity": False
        }
        score_dry = calculate_context_score("Outdoor Fitness", dry_sunny)
        score_storm = calculate_context_score("Outdoor Fitness", stormy)
        self.assertGreater(score_dry, score_storm, "Dry sunny morning should score higher than stormy weather for fitness")
        self.assertGreaterEqual(score_dry, 85.0)

    def test_beach_surf_logic(self):
        """Verify warm sunny afternoon scores well for Beach & Surf."""
        beach_day = {
            "hour": 14,
            "temperature": 28,
            "rain_probability": 0,
            "wind_speed": 18,
            "uv_index": 6,
            "visibility": 10
        }
        score = calculate_context_score("Beach & Surf", beach_day)
        self.assertGreaterEqual(score, 80.0)

    def test_safety_alert_override(self):
        """Verify safety override boosts widgets correctly."""
        base_scores = {
            "Commuter": 40.0,
            "Travel": 35.0,
            "Family": 50.0,
            "Health": 30.0,
            "Outdoor Fitness": 60.0
        }
        alerts = [{"type": "storm"}]
        updated = apply_safety_override(base_scores, alerts, override_score=95.0)

        self.assertEqual(updated["Commuter"], 95.0)
        self.assertEqual(updated["Travel"], 95.0)
        self.assertEqual(updated["Family"], 95.0)
        self.assertEqual(updated["Health"], 30.0)  # Unaffected by storm

    def test_rank_widgets_output(self):
        """Verify full ranking pipeline works end-to-end and returns sorted pairs."""
        user_prefs = {
            "Health": 0.8,
            "Outdoor Fitness": 0.2,
            "Beach & Surf": 0.5,
            "Travel": 0.1,
            "Family": 0.5,
            "Agriculture": 0.0,
            "Commuter": 0.4,
            "Events": 0.0
        }
        ctx = {
            "hour": 7,
            "rain_probability": 20,
            "temperature": 25,
            "uv_index": 10,
            "wind_speed": 8,
            "visibility": 10,
            "commuting": True
        }
    def test_get_top_homepage_widgets(self):
        """Verify the mobile homepage helper returns top K structured dictionaries with badges."""
        from Scoring import get_top_homepage_widgets
        user_prefs = {"Health": 0.8, "Family": 0.5, "Commuter": 0.4}
        ctx = {"hour": 7, "temperature": 25, "uv_index": 9, "rain_probability": 10}
        top3 = get_top_homepage_widgets(user_prefs, ctx, top_k=3)

        self.assertEqual(len(top3), 3)
        self.assertEqual(top3[0]["rank"], 1)
        self.assertIn("badge", top3[0])
        self.assertIn("widget_id", top3[0])
        self.assertIn("title", top3[0])
        self.assertTrue(len(top3[0]["badge"]) > 0)


if __name__ == "__main__":
    unittest.main()

