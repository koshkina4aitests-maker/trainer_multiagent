from fastapi import APIRouter, Depends, Header, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.api.dependencies import get_db
from app.domain.models import IdempotencyKey, WorkoutSession
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
) -> WorkoutSession:
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
) -> WorkoutLogRead:
    return add_workout_log(db, session_id, payload)


@router.post("/sessions/{session_id}/complete", response_model=WorkoutSessionRead)
def complete_session(session_id: int, db: Session = Depends(get_db)) -> WorkoutSession:
    return complete_workout_session(db, session_id)


@router.get("/history/{user_id}", response_model=list[WorkoutSessionRead])
def history(user_id: int, db: Session = Depends(get_db)) -> list[WorkoutSession]:
    return list_workout_history(db, user_id)
