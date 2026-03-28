from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.dependencies import get_db
from app.schemas.auth import AuthResponse, GoogleSignInRequest
from app.services.auth_service import google_sign_in

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/google", response_model=AuthResponse)
def google_auth(payload: GoogleSignInRequest, db: Session = Depends(get_db)) -> AuthResponse:
    user, token = google_sign_in(db, payload)
    return AuthResponse(user_id=user.id, access_token=token)
