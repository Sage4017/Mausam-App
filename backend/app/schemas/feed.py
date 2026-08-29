from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field


class WidgetCard(BaseModel):
    """Represents a personalized widget card on the mobile dashboard."""
    rank: int = Field(..., description="1-indexed priority rank")
    widget_id: str = Field(..., description="Unique machine identifier for Flutter widget rendering")
    category: str = Field(..., description="Canonical category name")
    title: str = Field(..., description="Display title for UI")
    badge: str = Field(..., description="Dynamic contextual status badge")
    highlights: Dict[str, Any] = Field(default_factory=dict, description="Key card-specific highlights & metrics")


class HomeFeedResponse(BaseModel):
    """Personalized home feed response containing Hero and Scrollable cards."""
    status: str = "success"
    hero_count: int = 3
    weather_summary: Dict[str, Any] = Field(default_factory=dict, description="Current ambient weather context")
    primary_widgets: List[WidgetCard] = Field(..., description="Top 3 Hero cards displayed immediately")
    secondary_widgets: List[WidgetCard] = Field(..., description="Remaining scrollable cards")
    generated_at: str = Field(..., description="ISO timestamp of feed generation")


class CustomFeedRequest(BaseModel):
    """Payload to simulate custom feeds with arbitrary preferences or weather scenarios."""
    user_preferences: Optional[Dict[str, Any]] = None
    context_overrides: Optional[Dict[str, Any]] = None
    alerts: Optional[List[Dict[str, Any]]] = None
    hero_count: Optional[int] = 3
    mode: Optional[str] = "multiplicative"
