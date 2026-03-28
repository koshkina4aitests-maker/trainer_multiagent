from datetime import date

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.domain.models import Recommendation, User, WorkoutPlan, WorkoutSession, WorkoutSessionStatus


class RecommendationService:
    def __init__(self, session: Session) -> None:
        self.session = session

    def generate_for_user(self, user_id: int, current_condition: str) -> Recommendation:
        user = self.session.get(User, user_id)
        if user is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")

        latest_plan = self.session.scalar(
            select(WorkoutPlan)
            .where(WorkoutPlan.user_id == user_id)
            .order_by(WorkoutPlan.created_at.desc())
            .limit(1)
        )
        if latest_plan is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="No workout plan available for recommendation",
            )

        latest_session = self.session.scalar(
            select(WorkoutSession)
            .where(WorkoutSession.user_id == user_id)
            .order_by(WorkoutSession.created_at.desc())
            .limit(1)
        )

        rationale = self._build_rationale(current_condition=current_condition, latest_session=latest_session)

        recommendation = Recommendation(
            user_id=user_id,
            workout_plan_id=latest_plan.id,
            recommended_for=date.today(),
            rationale=rationale,
        )
        self.session.add(recommendation)
        self.session.commit()
        self.session.refresh(recommendation)
        return recommendation

    @staticmethod
    def _build_rationale(current_condition: str, latest_session: WorkoutSession | None) -> str:
        condition = current_condition.strip().lower()
        safety_clause = "Нагрузка сохранена умеренной."
        if any(flag in condition for flag in ("pain", "боль", "fatigue", "устал")):
            safety_clause = "Обнаружены признаки усталости/дискомфорта, поэтому рекомендована щадящая нагрузка."

        readiness_clause = "Текущее состояние учтено по вашему вводу перед тренировкой."

        progression_clause = "Прогрессия сохранена на уровне предыдущих сессий."
        if latest_session and latest_session.status == WorkoutSessionStatus.COMPLETED:
            progression_clause = "Учитывая завершенную прошлую сессию, можно постепенно повышать рабочий объем."

        return " ".join(
            [
                "Рекомендация сформирована на базе истории тренировок и текущего состояния.",
                safety_clause,
                readiness_clause,
                progression_clause,
                "План объясним: вы видите, какие факторы повлияли на выбор нагрузки.",
            ]
        )
