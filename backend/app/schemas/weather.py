from typing import Optional, Dict, Any
from pydantic import BaseModel, Field


class WeatherContextInput(BaseModel):
    """Optional weather context parameters passed by client."""
    latitude: Optional[float] = Field(None, description="GPS Latitude")
    longitude: Optional[float] = Field(None, description="GPS Longitude")
    climate_zone: Optional[str] = Field("tropical", description="tropical | temperate | arid | cold")
    temperature: Optional[float] = Field(None, description="Current temperature in °C")
    humidity: Optional[float] = Field(None, description="Relative humidity in %")
    rain_probability: Optional[float] = Field(None, description="Precipitation probability in %")
    wind_speed: Optional[float] = Field(None, description="Wind speed in km/h")
    uv_index: Optional[float] = Field(None, description="UV Index (0 - 12)")
    air_quality_index: Optional[float] = Field(None, description="US AQI score (0 - 500)")
    upcoming_trip: Optional[bool] = Field(False, description="Whether user has an upcoming trip")


class WeatherSummaryResponse(BaseModel):
    """Standardized current weather and environmental summary."""
    temperature: float
    apparent_temperature: Optional[float] = None
    humidity: float
    rain_probability: float
    wind_speed: float
    uv_index: float
    air_quality_index: float
    weather_condition: Optional[str] = "Clear"
    climate_zone: str = "tropical"
    source: str = "open-meteo"
