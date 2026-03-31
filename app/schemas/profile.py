from datetime import datetime

from pydantic import AliasChoices, BaseModel, Field


class UserProfileUpsertRequest(BaseModel):
    age: int = Field(ge=14, le=100)
    height_cm: int = Field(ge=100, le=250)
    weight_kg: int = Field(ge=30, le=300)
    full_name: str | None = Field(default=None, max_length=200)
    medical_notes: str = Field(default="", max_length=2000)
    training_context: str = Field(default="gym", pattern="^(gym|home|mixed)$")
    training_style: str = Field(
        default="fullbody",
        pattern="^(fullbody|split)$",
        validation_alias=AliasChoices("training_style", "workout_style"),
        serialization_alias="training_style",
    )


class UserProfileResponse(BaseModel):
    user_id: int
    full_name: str | None
    age: int
    height_cm: int
    weight_kg: int
    medical_notes: str
    training_context: str
    training_style: str


class GoalCreateRequest(BaseModel):
    goal_type: str = Field(pattern="^(weight_loss|strength|endurance|health)$")
    target_value: str = Field(min_length=1, max_length=100)


class GoalResponse(BaseModel):
    id: int
    user_id: int
    goal_type: str
    target_value: str
    created_at: datetime
