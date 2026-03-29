from typing import Literal

from pydantic import BaseModel, Field

from app.domain.models import ProgramType


class WorkoutPlanItemCreate(BaseModel):
    exercise_id: int | None = None
    exercise_name: str = Field(default="", max_length=200)
    sets: int = Field(ge=1, le=20)
    reps: int = Field(ge=1, le=100)
    weight_kg: int = Field(ge=0, le=500)
    rir_target: int = Field(ge=0, le=10)


class WorkoutPlanCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    program_type: ProgramType
    source: Literal["manual", "recommendation"] = "manual"
    recommendation_style: Literal["fullbody", "split_upper", "split_lower", "custom"] = "custom"
    notes: str = ""
    items: list[WorkoutPlanItemCreate] = Field(min_length=1)


class WorkoutPlanItemResponse(BaseModel):
    id: int
    exercise_id: int | None
    exercise_name: str
    sets: int
    reps: int
    weight_kg: int
    rir_target: int


class WorkoutPlanResponse(BaseModel):
    id: int
    user_id: int
    title: str
    program_type: ProgramType
    source: Literal["manual", "recommendation"]
    recommendation_style: Literal["fullbody", "split_upper", "split_lower", "custom"]
    notes: str
    items: list[WorkoutPlanItemResponse]

    model_config = {"from_attributes": True}

