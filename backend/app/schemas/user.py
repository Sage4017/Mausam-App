from typing import Dict, Any, List, Optional
from pydantic import BaseModel, Field


class OnboardingAnswersRequest(BaseModel):
    """
    Onboarding questionnaire answers.
    Keys can be canonical categories (e.g. 'Health', 'Outdoor Fitness')
    Values can be rating keywords ('vimp', 'imp', 'normal', 'low', 'not imp') or floats (0.0 - 1.0).
    """
    answers: Dict[str, Any] = Field(
        default_factory=dict,
        description="Dictionary mapping widget/interest categories to rating keywords or weights"
    )

    model_config = {
        "json_schema_extra": {
            "example": {
                "answers": {
                    "Health": "vimp",
                    "Outdoor Fitness": "normal",
                    "Beach & Surf": 0.5,
                    "Commuter": "imp",
                    "Travel": "low",
                    "Family": "imp",
                    "Agriculture": "not imp",
                    "Events": "low"
                }
            }
        }
    }


class UserProfileResponse(BaseModel):
    """Normalized user preferences profile."""
    status: str = "success"
    user_id: Optional[str] = "default_user"
    preferences: Dict[str, float]
    top_interests: List[str]
    message: str = "User preferences updated successfully"
