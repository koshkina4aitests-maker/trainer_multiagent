from collections.abc import Generator

from fastapi import Depends, Header, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.domain.models import IdempotencyKey, User
from app.infrastructure.db import get_db_session


def get_db() -> Generator[Session, None, None]:
    yield from get_db_session()


def get_current_user(
    db: Session = Depends(get_db),
    x_user_id: int = Header(alias="X-User-Id"),
) -> User:
    user = db.get(User, x_user_id)
    if user is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Unknown user")
    return user


def enforce_idempotency_key(
    operation: str,
    idempotency_key: str | None,
    db: Session,
) -> None:
    if not idempotency_key:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Idempotency-Key header is required for this operation",
        )

    existing = db.scalar(
        select(IdempotencyKey).where(
            IdempotencyKey.operation == operation,
            IdempotencyKey.key == idempotency_key,
        )
    )
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Duplicate idempotent operation",
        )

    db.add(IdempotencyKey(operation=operation, key=idempotency_key))
    db.commit()
