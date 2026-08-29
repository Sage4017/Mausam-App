import os
import sys
from typing import Any, Dict, List, Union
from fastapi import APIRouter, Body
from app.schemas.user import OnboardingAnswersRequest, UserProfileResponse

# Ensure backend root is accessible for User module
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))
BACKEND_ROOT = os.path.abspath(os.path.join(CURRENT_DIR, "..", "..", ".."))
if BACKEND_ROOT not in sys.path:
    sys.path.insert(0, BACKEND_ROOT)

from User import parse_user_preferences

router = APIRouter(prefix="/onboarding", tags=["User Onboarding"])


@router.post(
    "/answers",
    response_model=UserProfileResponse,
    summary="Submit onboarding questionnaire answers",
    description="Parses user survey choices (text ratings like 'vimp' or weights) into normalized affinity profiles.",
)
async def submit_onboarding_answers(
    payload: Union[OnboardingAnswersRequest, Dict[str, Any]] = Body(...)
):
    # Support both wrapped {"answers": {...}} and direct dictionary payload
    raw_dict: Dict[str, Any] = {}
    if isinstance(payload, OnboardingAnswersRequest):
        raw_dict = payload.answers
    elif isinstance(payload, dict):
        raw_dict = payload.get("answers", payload)

    parsed_weights = parse_user_preferences(raw_dict)

    # Sort interests to extract top affinities
    sorted_interests: List[str] = sorted(
        parsed_weights.keys(),
        key=lambda k: parsed_weights[k],
        reverse=True
    )
    top_interests = [k for k in sorted_interests if parsed_weights[k] >= 0.5][:3]

    return UserProfileResponse(
        status="success",
        user_id="user_active",
        preferences=parsed_weights,
        top_interests=top_interests,
        message="Onboarding preferences successfully calibrated.",
    )
