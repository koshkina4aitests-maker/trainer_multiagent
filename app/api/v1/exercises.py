from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_db
from app.schemas.exercises import ExerciseCreateRequest, ExerciseResponse
from app.services.exercise_service import create_exercise, list_exercises

router = APIRouter(prefix="/exercises", tags=["exercises"])


@router.post("", response_model=ExerciseResponse, status_code=status.HTTP_201_CREATED)
def create_exercise_endpoint(
    payload: ExerciseCreateRequest,
    db: Session = Depends(get_db),
) -> ExerciseResponse:
    try:
        exercise = create_exercise(db, payload)
    except ValueError as exc:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc)) from exc
    return ExerciseResponse.model_validate(exercise, from_attributes=True)


@router.get("", response_model=list[ExerciseResponse])
def list_exercises_endpoint(db: Session = Depends(get_db)) -> list[ExerciseResponse]:
    exercises = list_exercises(db)
    return [ExerciseResponse.model_validate(exercise, from_attributes=True) for exercise in exercises]
