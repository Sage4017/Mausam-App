import os
import sys
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# Ensure parent directory (containing Scoring.py, User.py, context.py, etc.) is in sys.path
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_ROOT = os.path.abspath(os.path.join(CURRENT_DIR, ".."))
if BACKEND_ROOT not in sys.path:
    sys.path.insert(0, BACKEND_ROOT)

from app.api.v1.router import api_v1_router
from app.api.v1.endpoints.homepage import router as homepage_router
from app.api.v1.endpoints.onboarding import router as onboarding_router

app = FastAPI(
    title="Mausam AI Backend",
    description="Hyper-Personalized Contextual Weather & Widget Scoring Engine for Mausam Mobile App",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Enable CORS for Flutter mobile emulator, web, and local development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount versioned API routes (/api/v1/homepage, /api/v1/onboarding, /api/v1/weather)
app.include_router(api_v1_router)

# Mount direct root routes for 100% backward-compatibility with Flutter's ApiClient
app.include_router(homepage_router)
app.include_router(onboarding_router)


@app.get("/", tags=["System"])
def root():
    return {
        "app": "Mausam AI Backend",
        "status": "online",
        "version": "1.0.0",
        "docs": "/docs",
        "endpoints": {
            "homepage": "/homepage",
            "onboarding": "/onboarding/answers",
            "weather": "/api/v1/weather/current",
            "health": "/health",
        },
    }


@app.get("/health", tags=["System"])
def health_check():
    return {
        "status": "healthy",
        "engine": "scoring_v1_active",
        "weather_provider": "open-meteo",
    }