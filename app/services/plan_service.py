from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.domain.models import Exercise, ProgramType, User, WorkoutPlan, WorkoutPlanItem
from app.schemas.plans import WorkoutPlanCreate, WorkoutPlanItemResponse, WorkoutPlanResponse


def create_plan(db: Session, user_id: int, payload: WorkoutPlanCreate) -> WorkoutPlanResponse:
    user = db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    requested_ids = {item.exercise_id for item in payload.items if item.exercise_id is not None}
    exercise_map: dict[int, Exercise] = {}
    if requested_ids:
        exercises = db.query(Exercise).filter(Exercise.id.in_(requested_ids)).all()
        exercise_map = {exercise.id: exercise for exercise in exercises}
        missing = requested_ids.difference(exercise_map.keys())
        if missing:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Exercises not found: {sorted(missing)}",
            )

    plan = WorkoutPlan(
        user_id=user_id,
        title=payload.title,
        program_type=payload.program_type,
        source=payload.source,
        recommendation_style=payload.recommendation_style,
        notes=payload.notes,
    )
    db.add(plan)
    db.flush()

    for item in payload.items:
        exercise = _resolve_exercise(
            db=db,
            exercise_map=exercise_map,
            exercise_id=item.exercise_id,
            exercise_name=item.exercise_name,
        )
        db.add(
            WorkoutPlanItem(
                plan_id=plan.id,
                exercise_id=exercise.id,
                sets=item.sets,
                reps=item.reps,
                weight_kg=item.weight_kg,
                rir_target=item.rir_target,
            )
        )
    db.commit()
    db.refresh(plan)
    return _to_plan_response(plan)


def list_user_plans(db: Session, user_id: int) -> list[WorkoutPlanResponse]:
    plans = db.query(WorkoutPlan).filter(WorkoutPlan.user_id == user_id).all()
    return [_to_plan_response(plan) for plan in plans]


def copy_recommendation_to_plan(
    db: Session,
    user_id: int,
    recommendation_exercises: list[dict],
    title: str = "Recommended workout",
    notes: str = "",
    recommendation_style: str = "custom",
) -> WorkoutPlanResponse:
    user = db.get(User, user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

    plan = WorkoutPlan(
        user_id=user_id,
        title=title,
        program_type=ProgramType.CUSTOM,
        source="recommendation",
        recommendation_style=recommendation_style,
        notes=notes,
    )
    db.add(plan)
    db.flush()

    created_items = 0
    for item in recommendation_exercises:
        exercise_id = item.get("exercise_id")
        exercise_name = (item.get("exercise_name") or item.get("name") or "").strip()
        if exercise_id is None and not exercise_name:
            continue
        exercise = None
        if exercise_id is not None:
            exercise = db.get(Exercise, exercise_id)
        if exercise is None:
            if not exercise_name:
                continue
            exercise = db.query(Exercise).filter(Exercise.name == exercise_name).one_or_none()
            if exercise is None:
                exercise = Exercise(name=exercise_name, muscle_group="custom", contraindications="")
                db.add(exercise)
                db.flush()

        db.add(
            WorkoutPlanItem(
                plan_id=plan.id,
                exercise_id=exercise.id,
                sets=max(1, int(item.get("sets", 3))),
                reps=max(1, int(item.get("reps", 10))),
                weight_kg=max(0, min(500, int(item.get("weight_kg", 0)))),
                rir_target=max(0, min(10, int(item.get("rir_target", item.get("rir", 2))))),
            )
        )
        created_items += 1

    if created_items == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Recommendation has no exercises to copy",
        )

    db.commit()
    db.refresh(plan)
    return _to_plan_response(plan)


def _to_plan_response(plan: WorkoutPlan) -> WorkoutPlanResponse:
    return WorkoutPlanResponse(
        id=plan.id,
        user_id=plan.user_id,
        title=plan.title,
        program_type=plan.program_type,
        source=plan.source,
        recommendation_style=plan.recommendation_style,
        notes=plan.notes,
        items=[
            WorkoutPlanItemResponse(
                id=item.id,
                exercise_id=item.exercise_id,
                exercise_name=item.exercise.name,
                sets=item.sets,
                reps=item.reps,
                weight_kg=item.weight_kg,
                rir_target=item.rir_target,
            )
            for item in plan.items
        ],
    )


def _resolve_exercise(
    db: Session,
    exercise_map: dict[int, Exercise],
    exercise_id: int | None,
    exercise_name: str,
) -> Exercise:
    if exercise_id is not None:
        exercise = exercise_map.get(exercise_id)
        if exercise is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Exercise not found: {exercise_id}",
            )
        return exercise

    clean_name = exercise_name.strip()
    if not clean_name:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="exercise_name is required when exercise_id is not provided",
        )
    exercise = db.query(Exercise).filter(Exercise.name == clean_name).one_or_none()
    if exercise is None:
        exercise = Exercise(name=clean_name, muscle_group="custom", contraindications="")
        db.add(exercise)
        db.flush()
    return exercise
