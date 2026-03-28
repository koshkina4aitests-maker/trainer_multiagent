from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.domain.models import Exercise, User, WorkoutPlan, WorkoutPlanItem
from app.schemas.plans import WorkoutPlanCreate, WorkoutPlanItemResponse, WorkoutPlanResponse


def create_plan(db: Session, user_id: int, payload: WorkoutPlanCreate) -> WorkoutPlanResponse:
    user = db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    exercise_ids = {item.exercise_id for item in payload.items}
    exercises = db.query(Exercise).filter(Exercise.id.in_(exercise_ids)).all()
    exercise_map = {exercise.id: exercise for exercise in exercises}

    missing = exercise_ids.difference(exercise_map.keys())
    if missing:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Exercises not found: {sorted(missing)}",
        )

    plan = WorkoutPlan(
        user_id=user_id,
        title=payload.title,
        program_type=payload.program_type,
        notes=payload.notes,
    )
    db.add(plan)
    db.flush()

    for item in payload.items:
        db.add(
            WorkoutPlanItem(
                plan_id=plan.id,
                exercise_id=item.exercise_id,
                sets=item.sets,
                reps=item.reps,
                rir_target=item.rir_target,
            )
        )
    db.commit()
    db.refresh(plan)
    return _to_plan_response(plan)


def list_user_plans(db: Session, user_id: int) -> list[WorkoutPlanResponse]:
    plans = db.query(WorkoutPlan).filter(WorkoutPlan.user_id == user_id).all()
    return [_to_plan_response(plan) for plan in plans]


def _to_plan_response(plan: WorkoutPlan) -> WorkoutPlanResponse:
    return WorkoutPlanResponse(
        id=plan.id,
        user_id=plan.user_id,
        title=plan.title,
        program_type=plan.program_type,
        notes=plan.notes,
        items=[
            WorkoutPlanItemResponse(
                id=item.id,
                exercise_id=item.exercise_id,
                exercise_name=item.exercise.name,
                sets=item.sets,
                reps=item.reps,
                rir_target=item.rir_target,
            )
            for item in plan.items
        ],
    )
