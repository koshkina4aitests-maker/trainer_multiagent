from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.domain.models import GoalType, User, UserGoal, UserProfile
from app.schemas.profile import GoalCreateRequest, UserProfileUpsertRequest


def get_user_or_404(session: Session, user_id: int) -> User:
    user = session.get(User, user_id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user


def upsert_profile(session: Session, user_id: int, payload: UserProfileUpsertRequest) -> UserProfile:
    user = get_user_or_404(session, user_id)
    profile = session.query(UserProfile).filter(UserProfile.user_id == user_id).one_or_none()
    if profile is None:
        profile = UserProfile(user_id=user_id)
        session.add(profile)

    if payload.full_name is not None:
        user.full_name = payload.full_name
    profile.age = payload.age
    profile.height_cm = payload.height_cm
    profile.weight_kg = payload.weight_kg
    profile.medical_notes = payload.medical_notes
    profile.training_context = payload.training_context
    profile.workout_style = payload.training_style
    session.commit()
    session.refresh(profile)
    return profile


def create_goal(session: Session, user_id: int, payload: GoalCreateRequest) -> UserGoal:
    get_user_or_404(session, user_id)
    goal = UserGoal(
        user_id=user_id,
        goal_type=GoalType(payload.goal_type),
        target_value=payload.target_value,
    )
    session.add(goal)
    session.commit()
    session.refresh(goal)
    return goal
