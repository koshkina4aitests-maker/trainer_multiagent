from fastapi import FastAPI

from app.api.v1.router import api_router
from app.core.config import get_settings
from app.infrastructure.db import Base, engine

settings = get_settings()
app = FastAPI(
    title=settings.app_name,
    version="0.1.0",
    openapi_url=f"{settings.api_v1_prefix}/openapi.json",
    docs_url=f"{settings.api_v1_prefix}/docs",
)


@app.on_event("startup")
def on_startup() -> None:
    Base.metadata.create_all(bind=engine)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


app.include_router(api_router, prefix=settings.api_v1_prefix)
