from fastapi import APIRouter

from app.api.v1 import auth, exercises, plans, profile, recommendations, safety, workouts

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(profile.router)
api_router.include_router(exercises.router)
api_router.include_router(plans.router)
api_router.include_router(workouts.router)
api_router.include_router(recommendations.router)
api_router.include_router(safety.router)
