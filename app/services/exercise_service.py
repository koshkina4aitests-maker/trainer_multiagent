from sqlalchemy import select
from sqlalchemy.orm import Session

from app.domain.models import Exercise
from app.schemas.exercises import ExerciseCreateRequest


def create_exercise(session: Session, payload: ExerciseCreateRequest) -> Exercise:
    existing = session.scalar(select(Exercise).where(Exercise.name == payload.name))
    if existing is not None:
        raise ValueError("Exercise with this name already exists")

    exercise = Exercise(
        name=payload.name.strip(),
        muscle_group=payload.muscle_group.strip(),
        contraindications=payload.contraindications.strip(),
    )
    session.add(exercise)
    session.commit()
    session.refresh(exercise)
    return exercise


def list_exercises(session: Session) -> list[Exercise]:
    return list(session.scalars(select(Exercise).order_by(Exercise.name.asc())).all())
