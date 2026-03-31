from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

from google.auth.transport import requests
from google.oauth2 import id_token

from app.core.config import get_settings

if TYPE_CHECKING:
    from app.core.config import Settings


class GoogleTokenValidationError(ValueError):
    pass


@dataclass(frozen=True)
class GoogleIdentity:
    google_sub: str
    email: str
    full_name: str


def _verify_with_google(token: str) -> dict:
    return id_token.verify_oauth2_token(token, requests.Request())


def _extract_allowed_audiences(settings: "Settings") -> list[str]:
    return [aud for aud in settings.google_oauth_client_ids.split(",") if aud]


def verify_google_id_token(token: str) -> GoogleIdentity:
    settings = get_settings()
    allowed_audiences = _extract_allowed_audiences(settings)
    if not settings.google_oauth_client_ids:
        raise GoogleTokenValidationError(
            "Google OAuth client IDs are not configured on backend."
        )

    try:
        payload = _verify_with_google(token)
    except Exception as exc:  # pragma: no cover - vendor exception surface
        raise GoogleTokenValidationError("Invalid Google ID token.") from exc

    audience = payload.get("aud")
    if audience not in allowed_audiences:
        raise GoogleTokenValidationError("Google token audience is not allowed.")

    google_sub = str(payload.get("sub", "")).strip()
    email = str(payload.get("email", "")).strip()
    full_name = str(payload.get("name", "")).strip()
    if not google_sub or not email:
        raise GoogleTokenValidationError("Google token is missing required claims.")

    # Full name can be absent in some privacy contexts.
    return GoogleIdentity(
        google_sub=google_sub,
        email=email,
        full_name=full_name,
    )
