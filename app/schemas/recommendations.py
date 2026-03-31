from datetime import date
from typing import Literal

from pydantic import BaseModel, Field
from app.domain.models import ProgramType


class RecommendationRequest(BaseModel):
    current_condition: str = Field(default="", max_length=2000)
    style: Literal["fullbody", "split_upper", "split_lower"] = "fullbody"


class RecommendedExercise(BaseModel):
    name: str
    sets: int = Field(ge=1, le=20)
    reps: int = Field(ge=1, le=100)
    weight_kg: float = Field(ge=0, le=500)
    rir: int = Field(ge=0, le=10)


class RecommendationResponse(BaseModel):
    recommendation_id: int
    recommended_for: date
    workout_plan_id: int | None
    style: Literal["fullbody", "split_upper", "split_lower"]
    rationale: str
    exercises: list[RecommendedExercise]
    intensity_label: Literal["easy", "moderate", "hard"] = "moderate"
    intensity_reason_short: str = Field(default="", max_length=120)


class RecommendationCopyToPlanRequest(BaseModel):
    title: str = Field(default="Recommended workout", min_length=1, max_length=200)
    program_type: ProgramType = ProgramType.CUSTOM
    notes: str = Field(default="", max_length=2000)
    source: Literal["manual", "recommendation"] = "recommendation"
    recommendation_style: Literal["fullbody", "split_upper", "split_lower", "custom"] = "custom"
    exercises: list[RecommendedExercise] | None = None
