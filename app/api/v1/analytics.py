from fastapi import APIRouter
from pydantic import BaseModel, Field

router = APIRouter(prefix="/analytics", tags=["analytics"])


class QuickActionTapEvent(BaseModel):
    action: str = Field(..., max_length=100)
    card: str = Field(..., max_length=100)
    user_id: int | None = None


@router.post("/quick-action-tap", status_code=204)
def record_quick_action_tap(event: QuickActionTapEvent) -> None:
    """Receive analytics event for secondary quick-action taps on Dashboard cards."""
