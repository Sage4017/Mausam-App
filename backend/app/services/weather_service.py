import datetime
from typing import Any, Dict, Optional
import httpx

# WMO Weather interpretation codes (http://www.nodc.noaa.gov/archive/arc0021/0002199/1.1/data/0-data/HTML/WMO-CODE/WMO4677.HTM)
WMO_WEATHER_CODES = {
    0: "Clear sky",
    1: "Mainly clear",
    2: "Partly cloudy",
    3: "Overcast",
    45: "Fog",
    48: "Depositing rime fog",
    51: "Light drizzle",
    53: "Moderate drizzle",
    55: "Dense drizzle",
    61: "Slight rain",
    63: "Moderate rain",
    65: "Heavy rain",
    71: "Slight snow",
    73: "Moderate snow",
    75: "Heavy snow",
    77: "Snow grains",
    80: "Slight rain showers",
    81: "Moderate rain showers",
    82: "Violent rain showers",
    85: "Slight snow showers",
    86: "Heavy snow showers",
    95: "Thunderstorm",
    96: "Thunderstorm with slight hail",
    99: "Thunderstorm with heavy hail",
}

DEFAULT_LATITUDE = 28.6139   # New Delhi
DEFAULT_LONGITUDE = 77.2090


class OpenMeteoWeatherService:
    """
    Asynchronous weather and air quality service powered by Open-Meteo.
    Free to use, high reliability, no API keys required.
    """

    def __init__(self, timeout: float = 8.0):
        self.forecast_url = "https://api.open-meteo.com/v1/forecast"
        self.air_quality_url = "https://air-quality-api.open-meteo.com/v1/air-quality"
        self.timeout = timeout

    async def fetch_weather_and_aqi(
        self,
        latitude: float = DEFAULT_LATITUDE,
        longitude: float = DEFAULT_LONGITUDE,
    ) -> Dict[str, Any]:
        """
        Fetches current weather and air quality simultaneously from Open-Meteo.
        """
        weather_params = {
            "latitude": latitude,
            "longitude": longitude,
            "current": "temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,rain,weather_code,wind_speed_10m,uv_index",
            "hourly": "precipitation_probability,uv_index",
            "forecast_days": 1,
            "timezone": "auto",
        }

        aqi_params = {
            "latitude": latitude,
            "longitude": longitude,
            "current": "us_aqi,pm2_5,pm10,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone,dust",
            "timezone": "auto",
        }

        weather_raw: Dict[str, Any] = {}
        aqi_raw: Dict[str, Any] = {}

        async with httpx.AsyncClient(timeout=self.timeout) as client:
            try:
                weather_res = await client.get(self.forecast_url, params=weather_params)
                if weather_res.status_code == 200:
                    weather_raw = weather_res.json()
            except Exception as e:
                print(f"[OpenMeteo] Warning: Weather fetch failed ({e}). Using standard defaults.")

            try:
                aqi_res = await client.get(self.air_quality_url, params=aqi_params)
                if aqi_res.status_code == 200:
                    aqi_raw = aqi_res.json()
            except Exception as e:
                print(f"[OpenMeteo] Warning: AQI fetch failed ({e}). Using standard defaults.")

        return {
            "weather": weather_raw,
            "air_quality": aqi_raw,
        }

    def build_context_payload(
        self,
        raw_data: Dict[str, Any],
        climate_zone: str = "tropical",
        custom_overrides: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """
        Transforms Open-Meteo raw responses into the standardized context dictionary
        consumed by Mausam's context.py scoring engine.
        """
        now = datetime.datetime.now()
        current_hour = now.hour

        weather_current = raw_data.get("weather", {}).get("current", {})
        weather_hourly = raw_data.get("weather", {}).get("hourly", {})
        aqi_current = raw_data.get("air_quality", {}).get("current", {})

        # Extract current rain probability if available from hourly array
        rain_prob = 0.0
        hourly_rain_probs = weather_hourly.get("precipitation_probability", [])
        if hourly_rain_probs and len(hourly_rain_probs) > current_hour:
            rain_prob = float(hourly_rain_probs[current_hour])
        elif weather_current.get("precipitation", 0) > 0:
            rain_prob = 80.0

        weather_code = weather_current.get("weather_code", 0)
        condition_name = WMO_WEATHER_CODES.get(weather_code, "Clear")

        # Standard context dictionary matching context.py structure
        context_dict: Dict[str, Any] = {
            "climate_zone": climate_zone,
            "hour": current_hour,
            "temperature": float(weather_current.get("temperature_2m", 25.0)),
            "apparent_temperature": float(weather_current.get("apparent_temperature", weather_current.get("temperature_2m", 25.0))),
            "humidity": float(weather_current.get("relative_humidity_2m", 60.0)),
            "rain_probability": float(rain_prob),
            "wind_speed": float(weather_current.get("wind_speed_10m", 10.0)),
            "uv_index": float(weather_current.get("uv_index", 5.0)),
            "air_quality_index": float(aqi_current.get("us_aqi", 65.0)),
            "pm2_5": float(aqi_current.get("pm2_5", 25.0)),
            "pm10": float(aqi_current.get("pm10", 45.0)),
            "dust": float(aqi_current.get("dust", 15.0)),
            "condition": condition_name,
            "wave_height": 1.2,
            "water_temp": 26.0,
            "upcoming_trip": False,
            "destination_temperature": 25.0,
            "destination_rain_prob": 20.0,
        }

        # Apply any manual overrides supplied by the client
        if custom_overrides:
            for k, v in custom_overrides.items():
                if v is not None:
                    context_dict[k] = v

        return context_dict

    async def get_live_context(
        self,
        latitude: float = DEFAULT_LATITUDE,
        longitude: float = DEFAULT_LONGITUDE,
        climate_zone: str = "tropical",
        custom_overrides: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """High-level helper to fetch live weather and return ready-to-score context dict."""
        raw_data = await self.fetch_weather_and_aqi(latitude=latitude, longitude=longitude)
        return self.build_context_payload(
            raw_data=raw_data,
            climate_zone=climate_zone,
            custom_overrides=custom_overrides,
        )


# Global singleton instance
weather_service = OpenMeteoWeatherService()
