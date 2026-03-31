from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "Fitness App Backend"
    api_v1_prefix: str = "/v1"
    database_url: str = "sqlite:///./fitness.db"
    redis_url: str = "redis://localhost:6379/0"
    celery_broker_url: str = "redis://localhost:6379/1"
    celery_result_backend: str = "redis://localhost:6379/2"
    celery_task_always_eager: bool = True
    # Comma-separated list of allowed Google OAuth client IDs.
    google_oauth_client_ids: str = ""
    # Test-only escape hatch for local integration tests.
    allow_insecure_test_google_tokens: bool = False

    model_config = SettingsConfigDict(
        env_prefix="FITNESS_",
        env_file=".env",
        case_sensitive=False,
    )

    @property
    def google_oauth_client_id_set(self) -> set[str]:
        return {
            item.strip()
            for item in self.google_oauth_client_ids.split(",")
            if item.strip()
        }


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()
