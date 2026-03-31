from fastapi import APIRouter

from app.schemas.safety import SafetyScreeningRequest, SafetyScreeningResponse
from app.services.safety_service import evaluate_safety

router = APIRouter(prefix="/safety", tags=["safety"])


@router.post("/screening", response_model=SafetyScreeningResponse)
def run_safety_screening(payload: SafetyScreeningRequest) -> SafetyScreeningResponse:
    return evaluate_safety(payload)
