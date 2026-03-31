from __future__ import annotations

from datetime import date, datetime
from enum import Enum

from sqlalchemy import Date, DateTime, Enum as SAEnum, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.infrastructure.db import Base


class GoalType(str, Enum):
    WEIGHT_LOSS = "weight_loss"
    STRENGTH = "strength"
    ENDURANCE = "endurance"
    HEALTH = "health"


class ProgramType(str, Enum):
    PREDEFINED = "predefined"
    CUSTOM = "custom"


class WorkoutSessionStatus(str, Enum):
    PLANNED = "planned"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String(320), unique=True, index=True)
    full_name: Mapped[str] = mapped_column(String(200))
    google_sub: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    profile: Mapped["UserProfile"] = relationship(back_populates="user", cascade="all, delete-orphan", uselist=False)
    goals: Mapped[list["UserGoal"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    plans: Mapped[list["WorkoutPlan"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    workout_sessions: Mapped[list["WorkoutSession"]] = relationship(back_populates="user", cascade="all, delete-orphan")
    recommendations: Mapped[list["Recommendation"]] = relationship(back_populates="user", cascade="all, delete-orphan")


class UserProfile(Base):
    __tablename__ = "user_profiles"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), unique=True, index=True)
    age: Mapped[int] = mapped_column(Integer)
    height_cm: Mapped[int] = mapped_column(Integer)
    weight_kg: Mapped[int] = mapped_column(Integer)
    medical_notes: Mapped[str] = mapped_column(Text, default="", nullable=False)
    training_context: Mapped[str] = mapped_column(String(50), default="gym", nullable=False)
    workout_style: Mapped[str] = mapped_column(String(50), default="fullbody", nullable=False)

    user: Mapped[User] = relationship(back_populates="profile")


class UserGoal(Base):
    __tablename__ = "user_goals"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    goal_type: Mapped[GoalType] = mapped_column(SAEnum(GoalType), nullable=False)
    target_value: Mapped[str] = mapped_column(String(100), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    user: Mapped[User] = relationship(back_populates="goals")


class Exercise(Base):
    __tablename__ = "exercises"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    name: Mapped[str] = mapped_column(String(200), unique=True, index=True)
    muscle_group: Mapped[str] = mapped_column(String(100))
    contraindications: Mapped[str] = mapped_column(Text, default="", nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    plan_items: Mapped[list["WorkoutPlanItem"]] = relationship(back_populates="exercise")
    logs: Mapped[list["WorkoutLog"]] = relationship(back_populates="exercise")


class WorkoutPlan(Base):
    __tablename__ = "workout_plans"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    title: Mapped[str] = mapped_column(String(200))
    program_type: Mapped[ProgramType] = mapped_column(SAEnum(ProgramType), nullable=False)
    source: Mapped[str] = mapped_column(String(50), default="manual", nullable=False)
    recommendation_style: Mapped[str] = mapped_column(String(50), default="custom", nullable=False)
    notes: Mapped[str] = mapped_column(Text, default="", nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    user: Mapped[User] = relationship(back_populates="plans")
    items: Mapped[list["WorkoutPlanItem"]] = relationship(back_populates="plan", cascade="all, delete-orphan")


class WorkoutPlanItem(Base):
    __tablename__ = "workout_plan_items"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    plan_id: Mapped[int] = mapped_column(ForeignKey("workout_plans.id"), index=True)
    exercise_id: Mapped[int] = mapped_column(ForeignKey("exercises.id"), index=True)
    sets: Mapped[int] = mapped_column(Integer)
    reps: Mapped[int] = mapped_column(Integer)
    rir_target: Mapped[int] = mapped_column(Integer)
    weight_kg: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    plan: Mapped[WorkoutPlan] = relationship(back_populates="items")
    exercise: Mapped[Exercise] = relationship(back_populates="plan_items")


class WorkoutSession(Base):
    __tablename__ = "workout_sessions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    plan_id: Mapped[int | None] = mapped_column(ForeignKey("workout_plans.id"), nullable=True, index=True)
    session_date: Mapped[date] = mapped_column(Date, default=date.today, nullable=False)
    status: Mapped[WorkoutSessionStatus] = mapped_column(SAEnum(WorkoutSessionStatus), default=WorkoutSessionStatus.PLANNED)
    current_condition: Mapped[str] = mapped_column(Text, default="", nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    user: Mapped[User] = relationship(back_populates="workout_sessions")
    logs: Mapped[list["WorkoutLog"]] = relationship(back_populates="session", cascade="all, delete-orphan")


class WorkoutLog(Base):
    __tablename__ = "workout_logs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    session_id: Mapped[int] = mapped_column(ForeignKey("workout_sessions.id"), index=True)
    exercise_id: Mapped[int] = mapped_column(ForeignKey("exercises.id"), index=True)
    sets: Mapped[int] = mapped_column(Integer)
    reps_per_set: Mapped[int] = mapped_column(Integer)
    weight_kg: Mapped[int] = mapped_column(Integer)
    rir: Mapped[int] = mapped_column(Integer)

    session: Mapped[WorkoutSession] = relationship(back_populates="logs")
    exercise: Mapped[Exercise] = relationship(back_populates="logs")


class Recommendation(Base):
    __tablename__ = "recommendations"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), index=True)
    workout_plan_id: Mapped[int | None] = mapped_column(ForeignKey("workout_plans.id"), nullable=True)
    recommended_for: Mapped[date] = mapped_column(Date, default=date.today, nullable=False)
    rationale: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)

    user: Mapped[User] = relationship(back_populates="recommendations")


class IdempotencyKey(Base):
    __tablename__ = "idempotency_keys"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    operation: Mapped[str] = mapped_column(String(100), index=True)
    key: Mapped[str] = mapped_column(String(255), unique=True, index=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False)
