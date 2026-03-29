from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user, get_db
from app.schemas.plans import WorkoutPlanCreate, WorkoutPlanResponse
from app.services.plan_service import create_plan, list_user_plans

router = APIRouter(prefix="/users/{user_id}/plans", tags=["plans"])


@router.post("", response_model=WorkoutPlanResponse, status_code=201)
def create_user_plan(
    user_id: int,
    payload: WorkoutPlanCreate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
) -> WorkoutPlanResponse:
    if current_user.id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")
    return create_plan(db, user_id=user_id, payload=payload)


@router.get("", response_model=list[WorkoutPlanResponse])
def get_user_plans(
    user_id: int,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
) -> list[WorkoutPlanResponse]:
    if current_user.id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")
    return list_user_plans(db, user_id=user_id)
