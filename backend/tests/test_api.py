import os
import sys
import unittest
from fastapi.testclient import TestClient

# Ensure backend root is in sys.path
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_ROOT = os.path.abspath(os.path.join(CURRENT_DIR, ".."))
if BACKEND_ROOT not in sys.path:
    sys.path.insert(0, BACKEND_ROOT)

from app.main import app


class TestFastAPIBackend(unittest.TestCase):

    def setUp(self):
        self.client = TestClient(app)

    def test_root_endpoint(self):
        """Test root / info endpoint."""
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data.get("status"), "online")
        self.assertIn("endpoints", data)

    def test_health_check(self):
        """Test /health endpoint."""
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data.get("status"), "healthy")
        self.assertEqual(data.get("weather_provider"), "open-meteo")

    def test_homepage_feed_default(self):
        """Test GET /homepage returns valid 3 Hero and 5 Scrollable cards."""
        response = self.client.get("/homepage")
        self.assertEqual(response.status_code, 200)
        data = response.json()

        self.assertEqual(data.get("status"), "success")
        self.assertEqual(data.get("hero_count"), 3)

        # Check primary cards
        primary = data.get("primary_widgets", [])
        self.assertEqual(len(primary), 3)
        for i, card in enumerate(primary, start=1):
            self.assertEqual(card["rank"], i)
            self.assertTrue(len(card["widget_id"]) > 0)
            self.assertTrue(len(card["title"]) > 0)
            self.assertIn("highlights", card)
            self.assertIn("badge", card)

        # Check secondary cards
        secondary = data.get("secondary_widgets", [])
        self.assertEqual(len(secondary), 5)
        for i, card in enumerate(secondary, start=4):
            self.assertEqual(card["rank"], i)

    def test_custom_feed_post(self):
        """Test POST /homepage/custom with simulated user preferences & weather."""
        payload = {
            "user_preferences": {
                "Health": 1.0,
                "Outdoor Fitness": 0.0,
                "Beach & Surf": 0.0,
                "Travel": 0.0,
                "Family": 0.0,
                "Agriculture": 0.0,
                "Commuter": 0.0,
                "Events": 0.0,
            },
            "context_overrides": {
                "temperature": 38,
                "air_quality_index": 220,
            },
            "hero_count": 3,
            "mode": "multiplicative",
        }
        response = self.client.post("/homepage/custom", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()

        primary = data.get("primary_widgets", [])
        self.assertEqual(len(primary), 3)
        # Health should be rank #1
        self.assertEqual(primary[0]["category"], "Health")

    def test_onboarding_answers(self):
        """Test POST /onboarding/answers with string keyword ratings."""
        payload = {
            "answers": {
                "Health": "vimp",
                "Outdoor Fitness": "imp",
                "Commuter": "normal",
                "Agriculture": "not imp",
            }
        }
        response = self.client.post("/onboarding/answers", json=payload)
        self.assertEqual(response.status_code, 200)
        data = response.json()

        self.assertEqual(data.get("status"), "success")
        prefs = data.get("preferences", {})
        self.assertEqual(prefs.get("Health"), 1.0)
        self.assertEqual(prefs.get("Outdoor Fitness"), 0.8)
        self.assertEqual(prefs.get("Commuter"), 0.5)
        self.assertEqual(prefs.get("Agriculture"), 0.0)

    def test_weather_current_endpoint(self):
        """Test GET /api/v1/weather/current."""
        response = self.client.get("/api/v1/weather/current")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data.get("status"), "success")
        self.assertIn("context", data)
        self.assertIn("temperature", data["context"])


if __name__ == "__main__":
    unittest.main()
