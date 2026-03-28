from fastapi import APIRouter, Depends, Header, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user, get_db
from app.domain.models import IdempotencyKey, WorkoutSession, WorkoutSessionStatus
from app.schemas.workouts import (
    WorkoutLogCreate,
    WorkoutLogRead,
    WorkoutSessionCreate,
    WorkoutSessionRead,
)
from app.services.workout_service import (
    add_workout_log,
    complete_workout_session,
    create_workout_session,
    list_workout_history,
)

router = APIRouter(prefix="/workouts", tags=["workouts"])


@router.post("/sessions", response_model=WorkoutSessionRead, status_code=status.HTTP_201_CREATED)
def create_session(
    payload: WorkoutSessionCreate,
    db: Session = Depends(get_db),
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    current_user=Depends(get_current_user),
) -> WorkoutSession:
    if current_user.id != payload.user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")

    if idempotency_key:
        existing = db.scalar(
            select(IdempotencyKey).where(
                IdempotencyKey.operation == "create_workout_session",
                IdempotencyKey.key == idempotency_key,
            )
        )
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Duplicate request blocked by idempotency key",
            )

    created = create_workout_session(db, payload)

    if idempotency_key:
        db.add(IdempotencyKey(operation="create_workout_session", key=idempotency_key))
        db.commit()

    return created


@router.post("/sessions/{session_id}/logs", response_model=WorkoutLogRead, status_code=status.HTTP_201_CREATED)
def create_log(
    session_id: int,
    payload: WorkoutLogCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
) -> WorkoutLogRead:
    workout_session = db.get(WorkoutSession, session_id)
    if workout_session is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workout session not found")
    if workout_session.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")
    if workout_session.status == WorkoutSessionStatus.COMPLETED:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Workout session already completed")
    return add_workout_log(db, session_id, payload)


@router.post("/sessions/{session_id}/complete", response_model=WorkoutSessionRead)
def complete_session(
    session_id: int,
    db: Session = Depends(get_db),
    idempotency_key: str | None = Header(default=None, alias="Idempotency-Key"),
    current_user=Depends(get_current_user),
) -> WorkoutSession:
    workout_session = db.get(WorkoutSession, session_id)
    if workout_session is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workout session not found")
    if workout_session.user_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")

    if idempotency_key:
        existing = db.scalar(
            select(IdempotencyKey).where(
                IdempotencyKey.operation == "complete_workout_session",
                IdempotencyKey.key == idempotency_key,
            )
        )
        if existing:
            # Repeated completion request is treated as idempotent success.
            if workout_session.status == WorkoutSessionStatus.COMPLETED:
                return workout_session
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Duplicate request blocked by idempotency key",
            )

    completed = complete_workout_session(db, session_id)

    if idempotency_key:
        db.add(IdempotencyKey(operation="complete_workout_session", key=idempotency_key))
        db.commit()

    return completed


@router.get("/history/{user_id}", response_model=list[WorkoutSessionRead])
def history(
    user_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
) -> list[WorkoutSession]:
    if current_user.id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")
    return list_workout_history(db, user_id)
