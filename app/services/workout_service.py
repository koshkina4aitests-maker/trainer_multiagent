from datetime import date

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.domain.models import Exercise, User, WorkoutLog, WorkoutSession, WorkoutSessionStatus
from app.schemas.workouts import WorkoutLogCreate, WorkoutSessionCreate
from app.workers.tasks import recompute_user_progress, send_workout_completion_message


def create_workout_session(db: Session, payload: WorkoutSessionCreate) -> WorkoutSession:
    user = db.get(User, payload.user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    session = WorkoutSession(
        user_id=payload.user_id,
        plan_id=payload.plan_id,
        session_date=payload.session_date or date.today(),
        current_condition=payload.current_condition,
        status=WorkoutSessionStatus.IN_PROGRESS,
    )
    db.add(session)
    db.commit()
    db.refresh(session)
    return session


def add_workout_log(db: Session, session_id: int, payload: WorkoutLogCreate) -> WorkoutLog:
    workout_session = db.get(WorkoutSession, session_id)
    if not workout_session:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workout session not found")
    if workout_session.status == WorkoutSessionStatus.COMPLETED:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Workout session already completed")

    exercise = db.get(Exercise, payload.exercise_id)
    if not exercise:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Exercise not found")

    log = WorkoutLog(
        session_id=session_id,
        exercise_id=payload.exercise_id,
        sets=payload.sets,
        reps_per_set=payload.reps_per_set,
        weight_kg=payload.weight_kg,
        rir=payload.rir,
    )
    db.add(log)
    db.commit()
    db.refresh(log)
    return log


def complete_workout_session(db: Session, session_id: int) -> WorkoutSession:
    workout_session = db.get(WorkoutSession, session_id)
    if not workout_session:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Workout session not found")
    workout_session.status = WorkoutSessionStatus.COMPLETED
    db.add(workout_session)
    db.commit()
    db.refresh(workout_session)
    send_workout_completion_message.delay(workout_session.user_id, workout_session.id)
    recompute_user_progress.delay(workout_session.user_id)
    return workout_session


def list_workout_history(db: Session, user_id: int) -> list[WorkoutSession]:
    stmt = (
        select(WorkoutSession)
        .where(WorkoutSession.user_id == user_id)
        .order_by(WorkoutSession.session_date.desc(), WorkoutSession.id.desc())
    )
    return list(db.scalars(stmt).all())
