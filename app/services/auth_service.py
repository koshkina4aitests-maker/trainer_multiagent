from __future__ import annotations

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.domain.models import User
from app.schemas.auth import GoogleSignInRequest
from app.services.google_auth import GoogleIdentity, verify_google_id_token


def google_sign_in(session: Session, payload: GoogleSignInRequest) -> tuple[User, str]:
    identity: GoogleIdentity = verify_google_id_token(payload.id_token)
    user = session.scalar(select(User).where(User.google_sub == identity.google_sub))
    if user is None:
        user = User(
            email=identity.email,
            full_name=identity.full_name,
            google_sub=identity.google_sub,
        )
        session.add(user)
        session.commit()
        session.refresh(user)
    else:
        user.email = identity.email
        user.full_name = identity.full_name
        session.commit()
        session.refresh(user)

    # JWT/OIDC access token should be issued by dedicated auth provider in production.
    access_token = f"dev-token-user-{user.id}"
    return user, access_token
