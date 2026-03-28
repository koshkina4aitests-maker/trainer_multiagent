from datetime import date
from typing import Literal

from pydantic import BaseModel, Field


class RecommendationRequest(BaseModel):
    current_condition: str = Field(default="", max_length=2000)


class RecommendationResponse(BaseModel):
    recommendation_id: int
    recommended_for: date
    workout_plan_id: int | None
    rationale: str
    intensity_label: Literal["easy", "moderate", "hard"] = "moderate"
    intensity_reason_short: str = Field(default="", max_length=120)
