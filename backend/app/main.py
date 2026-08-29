from fastapi import FastAPI

app = FastAPI(
    title="Mausam Backend",
    description="Backend API for the Mausam personalized weather application",
    version="0.1.0",
)


@app.get("/")
def root():
    return {
        "message": "Mausam backend is running",
        "status": "ok",
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy",
    }