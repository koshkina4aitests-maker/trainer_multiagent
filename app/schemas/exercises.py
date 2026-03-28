from pydantic import BaseModel, Field


class ExerciseCreateRequest(BaseModel):
    name: str = Field(min_length=1, max_length=200)
    muscle_group: str = Field(min_length=1, max_length=100)
    contraindications: str = Field(default="", max_length=2000)


class ExerciseResponse(BaseModel):
    id: int
    name: str
    muscle_group: str
    contraindications: str
