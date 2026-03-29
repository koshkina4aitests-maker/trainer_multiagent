from fastapi import APIRouter, Depends, Header, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user, get_db
from app.domain.models import IdempotencyKey, Recommendation, WorkoutPlan
from app.schemas.plans import WorkoutPlanResponse
from app.schemas.recommendations import (
    RecommendationCopyToPlanRequest,
    RecommendationRequest,
    RecommendationResponse,
)
from app.services.plan_service import copy_recommendation_to_plan
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
    data = RecommendationService(db).generate_for_user(
        user_id=user_id,
        current_condition=payload.current_condition,
        style=payload.style,
    )
    return RecommendationResponse(**data)


@router.post(
    "/{recommendation_id}/copy-to-plan",
    response_model=WorkoutPlanResponse,
    status_code=status.HTTP_201_CREATED,
)
def copy_recommendation_to_plan_endpoint(
    user_id: int,
    recommendation_id: int,
    payload: RecommendationCopyToPlanRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
) -> WorkoutPlanResponse:
    if current_user.id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")

    recommendation = (
        db.query(Recommendation)
        .filter(Recommendation.id == recommendation_id, Recommendation.user_id == user_id)
        .one_or_none()
    )
    if recommendation is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Recommendation not found")

    if payload.exercises is not None:
        exercises_payload = [exercise.model_dump() for exercise in payload.exercises]
    else:
        if recommendation.workout_plan_id is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Recommendation is not linked to a source workout plan",
            )
        source_plan = db.get(WorkoutPlan, recommendation.workout_plan_id)
        if source_plan is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Source workout plan for recommendation not found",
            )
        exercises_payload = [
            {
                "exercise_id": item.exercise_id,
                "exercise_name": item.exercise.name,
                "sets": item.sets,
                "reps": item.reps,
                "weight_kg": item.weight_kg,
                "rir": item.rir_target,
            }
            for item in source_plan.items
        ]

    return copy_recommendation_to_plan(
        db=db,
        user_id=user_id,
        recommendation_exercises=exercises_payload,
        title=payload.title,
        notes=payload.notes,
        recommendation_style=payload.recommendation_style,
    )
