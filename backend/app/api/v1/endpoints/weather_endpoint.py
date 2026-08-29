from fastapi import APIRouter, Query
from app.services.weather_service import weather_service, DEFAULT_LATITUDE, DEFAULT_LONGITUDE

router = APIRouter(prefix="/weather", tags=["Live Weather & Context"])


@router.get(
    "/current",
    summary="Get real-time ambient weather & air quality context",
    description="Queries Open-Meteo for live environmental conditions, AQI, and atmospheric metrics.",
)
async def get_current_weather(
    lat: float = Query(DEFAULT_LATITUDE, description="User GPS latitude"),
    lon: float = Query(DEFAULT_LONGITUDE, description="User GPS longitude"),
    climate_zone: str = Query("tropical", description="tropical | temperate | arid | cold"),
):
    ctx = await weather_service.get_live_context(
        latitude=lat,
        longitude=lon,
        climate_zone=climate_zone,
    )
    return {
        "status": "success",
        "context": ctx,
    }
