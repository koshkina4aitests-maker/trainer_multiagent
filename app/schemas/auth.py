from pydantic import BaseModel, Field


class GoogleSignInRequest(BaseModel):
    email: str = Field(min_length=5, max_length=320)
    full_name: str = Field(min_length=1, max_length=200)
    google_sub: str = Field(min_length=1, max_length=255)


class AuthResponse(BaseModel):
    user_id: int
    access_token: str
    token_type: str = "bearer"
