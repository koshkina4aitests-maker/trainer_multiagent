from pydantic import BaseModel, Field

from app.domain.models import ProgramType


class WorkoutPlanItemCreate(BaseModel):
    exercise_id: int
    sets: int = Field(ge=1, le=20)
    reps: int = Field(ge=1, le=100)
    rir_target: int = Field(ge=0, le=10)


class WorkoutPlanCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    program_type: ProgramType
    notes: str = ""
    items: list[WorkoutPlanItemCreate] = Field(min_length=1)


class WorkoutPlanItemResponse(BaseModel):
    id: int
    exercise_id: int
    exercise_name: str
    sets: int
    reps: int
    rir_target: int


class WorkoutPlanResponse(BaseModel):
    id: int
    user_id: int
    title: str
    program_type: ProgramType
    notes: str
    items: list[WorkoutPlanItemResponse]

    model_config = {"from_attributes": True}

