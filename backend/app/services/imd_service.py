import httpx
from typing import Any


IMD_BASE_URL = "https://api.imd.gov.in/api/v1"


class IMDService:
    """
    Service responsible for communicating with the
    India Meteorological Department APIs.
    """

    def __init__(self):
        self.base_url = IMD_BASE_URL

    async def get_current_weather(
        self,
        station_id: str | None = None
    ) -> Any:

        url = f"{self.base_url}/current_wx"

        params = {}

        if station_id:
            params["id"] = station_id

        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(
                url,
                params=params
            )

        response.raise_for_status()

        return response.json()

if __name__ == "__main__":
    import asyncio

    async def test():
        service = IMDService()

        data = await service.get_current_weather()

        print(data)

    asyncio.run(test())