from typing import Optional
from fastapi import APIRouter, Query
from app.schemas.feed import HomeFeedResponse, CustomFeedRequest
from app.services.feed_service import feed_service
from app.services.weather_service import DEFAULT_LATITUDE, DEFAULT_LONGITUDE

router = APIRouter(prefix="/homepage", tags=["Homepage Feed"])


@router.get(
    "",
    response_model=HomeFeedResponse,
    summary="Get personalized mobile homepage feed",
    description="Returns the Top 3 Hero widget cards and 5 Scrollable cards personalized with live weather.",
)
async def get_homepage_feed(
    lat: float = Query(DEFAULT_LATITUDE, description="User GPS latitude"),
    lon: float = Query(DEFAULT_LONGITUDE, description="User GPS longitude"),
    climate_zone: str = Query("tropical", description="tropical | temperate | arid | cold"),
    hero_count: int = Query(3, ge=1, le=8, description="Number of primary hero cards"),
):
    return await feed_service.get_personalized_feed(
        latitude=lat,
        longitude=lon,
        climate_zone=climate_zone,
        hero_count=hero_count,
    )


@router.post(
    "/custom",
    response_model=HomeFeedResponse,
    summary="Generate feed with custom preferences and weather simulation",
    description="Allows testing arbitrary user preference ratings, weather parameters, and severe alerts.",
)
async def generate_custom_feed(request: CustomFeedRequest):
    return await feed_service.get_personalized_feed(
        user_prefs=request.user_preferences,
        custom_context=request.context_overrides,
        alerts=request.alerts,
        hero_count=request.hero_count or 3,
        mode=request.mode or "multiplicative",
    )
