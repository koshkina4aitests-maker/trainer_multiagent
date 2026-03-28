# syntax=docker/dockerfile:1.6
FROM python:3.12-slim AS base

WORKDIR /app

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

COPY pyproject.toml .

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir \
        "fastapi>=0.115.0" \
        "uvicorn[standard]>=0.30.0" \
        "sqlalchemy>=2.0.30" \
        "pydantic-settings>=2.4.0" \
        "celery>=5.4.0" \
        "redis>=5.0.0" \
        "pytest>=8.2.0" \
        "httpx>=0.27.0"

COPY app/ app/
COPY tests/ tests/

RUN python -m compileall -q app/

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD curl -fsS http://localhost:8000/health || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
