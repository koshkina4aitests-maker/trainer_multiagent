from pydantic import BaseModel, Field


class GoogleSignInRequest(BaseModel):
    id_token: str = Field(min_length=20, max_length=4096)


class AuthResponse(BaseModel):
    user_id: int
    access_token: str
    token_type: str = "bearer"
