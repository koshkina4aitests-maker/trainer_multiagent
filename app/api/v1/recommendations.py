from fastapi import APIRouter, Depends, Header, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user, get_db
from app.domain.models import IdempotencyKey
from app.schemas.recommendations import RecommendationRequest, RecommendationResponse
from app.services.recommendation_service import RecommendationService

router = APIRouter(prefix="/users/{user_id}/recommendations", tags=["recommendations"])


def _guard_idempotency(db: Session, key: str | None, operation: str) -> None:
    if key is None:
        return
    existing = db.query(IdempotencyKey).filter(IdempotencyKey.key == key).one_or_none()
    if existing is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Duplicate request blocked by idempotency key",
        )
    db.add(IdempotencyKey(key=key, operation=operation))
    db.commit()


@router.post("", response_model=RecommendationResponse)
def generate_recommendation(
    user_id: int,
    payload: RecommendationRequest,
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
) -> RecommendationResponse:
    if current_user.id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")
    _guard_idempotency(db, idempotency_key, "generate_recommendation")
    recommendation = RecommendationService(db).generate_for_user(user_id=user_id, current_condition=payload.current_condition)
    return RecommendationResponse(
        recommendation_id=recommendation.id,
        recommended_for=recommendation.recommended_for,
        workout_plan_id=recommendation.workout_plan_id,
        rationale=recommendation.rationale,
    )
