from collections.abc import Iterator

from sqlalchemy import create_engine, inspect, text
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker

from app.core.config import get_settings


class Base(DeclarativeBase):
    pass


settings = get_settings()
engine = create_engine(
    settings.database_url,
    connect_args={"check_same_thread": False} if settings.database_url.startswith("sqlite") else {},
)
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False, class_=Session)


def init_db() -> None:
    # Import models so SQLAlchemy metadata includes all tables before create_all.
    from app.domain import models  # noqa: F401

    Base.metadata.create_all(bind=engine)
    _apply_sqlite_additive_migrations()


def _apply_sqlite_additive_migrations() -> None:
    # Local dev/prod currently uses SQLite without Alembic; add only backward-compatible columns.
    if not settings.database_url.startswith("sqlite"):
        return

    column_specs = {
        "user_profiles": {
            "workout_style": "VARCHAR(50) NOT NULL DEFAULT 'fullbody'",
        },
        "workout_plans": {
            "source": "VARCHAR(50) NOT NULL DEFAULT 'manual'",
            "recommendation_style": "VARCHAR(50) NOT NULL DEFAULT 'custom'",
        },
        "workout_plan_items": {
            "weight_kg": "INTEGER NOT NULL DEFAULT 0",
        },
    }

    with engine.begin() as connection:
        inspector = inspect(connection)
        for table_name, columns in column_specs.items():
            existing_columns = {column["name"] for column in inspector.get_columns(table_name)}
            for column_name, column_sql in columns.items():
                if column_name in existing_columns:
                    continue
                connection.execute(text(f"ALTER TABLE {table_name} ADD COLUMN {column_name} {column_sql}"))


def get_db_session() -> Iterator[Session]:
    session = SessionLocal()
    try:
        yield session
    finally:
        session.close()
