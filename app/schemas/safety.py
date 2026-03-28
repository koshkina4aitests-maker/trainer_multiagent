from pydantic import BaseModel, Field


class SafetyScreeningRequest(BaseModel):
    current_condition: str = Field(default="", max_length=2000)
    has_sharp_pain: bool = False
    has_dizziness: bool = False
    chest_pain: bool = False
    heart_rate_recovery_seconds: int | None = Field(default=None, ge=0, le=600)


class SafetyScreeningResponse(BaseModel):
    risk_level: str
    warnings: list[str]
    emergency_guidance: str
