from datetime import date

from pydantic import BaseModel, Field

from app.domain.models import WorkoutSessionStatus


class WorkoutSessionCreate(BaseModel):
    user_id: int = Field(gt=0)
    plan_id: int | None = Field(default=None, gt=0)
    session_date: date | None = None
    current_condition: str = Field(default="", max_length=1000)


class WorkoutSessionRead(BaseModel):
    id: int
    user_id: int
    plan_id: int | None
    session_date: date
    status: WorkoutSessionStatus
    current_condition: str

    model_config = {"from_attributes": True}


class WorkoutLogCreate(BaseModel):
    exercise_id: int = Field(gt=0)
    sets: int = Field(ge=1, le=20)
    reps_per_set: int = Field(ge=1, le=100)
    weight_kg: int = Field(ge=0, le=500)
    rir: int = Field(ge=0, le=10)


class WorkoutLogRead(BaseModel):
    id: int
    session_id: int
    exercise_id: int
    sets: int
    reps_per_set: int
    weight_kg: int
    rir: int

    model_config = {"from_attributes": True}
