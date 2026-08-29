from fastapi import APIRouter
from app.api.v1.endpoints.homepage import router as homepage_router
from app.api.v1.endpoints.onboarding import router as onboarding_router
from app.api.v1.endpoints.weather_endpoint import router as weather_router

api_v1_router = APIRouter(prefix="/api/v1")

# Include sub-routers
api_v1_router.include_router(homepage_router)
api_v1_router.include_router(onboarding_router)
api_v1_router.include_router(weather_router)
