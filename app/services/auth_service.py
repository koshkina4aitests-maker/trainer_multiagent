from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.domain.models import User
from app.schemas.auth import GoogleSignInRequest


def google_sign_in(session: Session, payload: GoogleSignInRequest) -> tuple[User, str]:
    user = session.scalar(select(User).where(User.google_sub == payload.google_sub))
    if user is None:
        user = User(
            email=payload.email,
            full_name=payload.full_name,
            google_sub=payload.google_sub,
        )
        session.add(user)
        session.commit()
        session.refresh(user)
    else:
        user.email = payload.email
        user.full_name = payload.full_name
        session.commit()
        session.refresh(user)

    # JWT/OIDC access token should be issued by dedicated auth provider in production.
    access_token = f"dev-token-user-{user.id}"
    return user, access_token
