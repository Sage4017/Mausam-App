import os
import sys
import datetime
from typing import Any, Dict, List, Optional

# Ensure parent directory (containing Scoring.py, User.py, context.py, etc.) is in sys.path
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_ROOT = os.path.abspath(os.path.join(CURRENT_DIR, "..", ".."))
if BACKEND_ROOT not in sys.path:
    sys.path.insert(0, BACKEND_ROOT)

from Scoring import get_home_feed
from User import user as DEFAULT_USER_PREFS, parse_user_preferences
from app.services.weather_service import weather_service, DEFAULT_LATITUDE, DEFAULT_LONGITUDE
from app.schemas.feed import HomeFeedResponse, WidgetCard


class FeedService:
    """
    Orchestration service combining live Open-Meteo weather context,
    user affinity models, and the Mausam ranking algorithm.
    """

    async def get_personalized_feed(
        self,
        user_prefs: Optional[Dict[str, Any]] = None,
        latitude: float = DEFAULT_LATITUDE,
        longitude: float = DEFAULT_LONGITUDE,
        climate_zone: str = "tropical",
        custom_context: Optional[Dict[str, Any]] = None,
        alerts: Optional[List[Dict[str, Any]]] = None,
        hero_count: int = 3,
        mode: str = "multiplicative",
    ) -> HomeFeedResponse:
        """
        Fetches live weather context, normalizes user preferences,
        computes top widget cards, and produces the complete dashboard payload.
        """
        # 1. Resolve user preferences
        if user_prefs:
            active_prefs = parse_user_preferences(user_prefs)
        else:
            active_prefs = parse_user_preferences(DEFAULT_USER_PREFS)

        # 2. Fetch live Open-Meteo context with any client overrides
        ctx = await weather_service.get_live_context(
            latitude=latitude,
            longitude=longitude,
            climate_zone=climate_zone,
            custom_overrides=custom_context,
        )

        # 3. Execute Mausam Scoring & Ranking Engine
        raw_feed = get_home_feed(
            user_prefs=active_prefs,
            ctx=ctx,
            alerts=alerts,
            hero_count=hero_count,
            mode=mode,
        )

        # 4. Map to Pydantic models
        primary_cards = [WidgetCard(**card) for card in raw_feed.get("primary_widgets", [])]
        secondary_cards = [WidgetCard(**card) for card in raw_feed.get("secondary_widgets", [])]

        weather_summary = {
            "temperature": ctx.get("temperature", 25.0),
            "apparent_temperature": ctx.get("apparent_temperature", 25.0),
            "humidity": ctx.get("humidity", 60.0),
            "rain_probability": ctx.get("rain_probability", 0.0),
            "wind_speed": ctx.get("wind_speed", 10.0),
            "uv_index": ctx.get("uv_index", 5.0),
            "air_quality_index": ctx.get("air_quality_index", 65.0),
            "condition": ctx.get("condition", "Clear"),
            "climate_zone": ctx.get("climate_zone", "tropical"),
            "latitude": latitude,
            "longitude": longitude,
        }

        return HomeFeedResponse(
            status="success",
            hero_count=hero_count,
            weather_summary=weather_summary,
            primary_widgets=primary_cards,
            secondary_widgets=secondary_cards,
            generated_at=datetime.datetime.now(datetime.timezone.utc).isoformat(),
        )


# Global singleton instance
feed_service = FeedService()
