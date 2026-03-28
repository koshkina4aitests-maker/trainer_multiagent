from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.api.dependencies import get_current_user, get_db
from app.domain.models import UserGoal
from app.schemas.profile import GoalCreateRequest, GoalResponse, UserProfileResponse, UserProfileUpsertRequest
from app.services.profile_service import create_goal, upsert_profile

router = APIRouter(prefix="/users/{user_id}", tags=["profile"])


@router.put("/profile", response_model=UserProfileResponse)
def put_profile(
    user_id: int,
    payload: UserProfileUpsertRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
) -> UserProfileResponse:
    if current_user.id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")

    profile = upsert_profile(db, user_id=user_id, payload=payload)
    return UserProfileResponse(
        user_id=profile.user_id,
        age=profile.age,
        height_cm=profile.height_cm,
        weight_kg=profile.weight_kg,
        medical_notes=profile.medical_notes,
        training_context=profile.training_context,
    )


@router.post("/goals", response_model=GoalResponse, status_code=status.HTTP_201_CREATED)
def post_goal(
    user_id: int,
    payload: GoalCreateRequest,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
) -> GoalResponse:
    if current_user.id != user_id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden")

    goal: UserGoal = create_goal(db, user_id=user_id, payload=payload)
    return GoalResponse(
        id=goal.id,
        user_id=goal.user_id,
        goal_type=goal.goal_type.value,
        target_value=goal.target_value,
        created_at=goal.created_at,
    )
