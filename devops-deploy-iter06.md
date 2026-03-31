# DevOps Deploy Report — iter-06

## Credentials handling
- deployment credentials were requested/used only for deployment execution.
- auth method used: `SERVER_PASSWORD` over SSH.
- secret values were not written to repository files or shared memory artifacts.
- post-use cleanup executed: sensitive env vars unset locally after deploy verification.

## Target
- host: `95.81.124.133`
- user: `root`
- app path: `/opt/fitness-app`
- deployed branch: `cursor/-bc-831ea3ed-7836-4c29-9827-ecb063ed9331-6179`

## Deployment actions
1. Connect to server and verify repo state in `/opt/fitness-app`.
2. Resolve checkout blocker (`docker-compose.yml` local modification) via temporary stash on server.
3. Checkout and pull target branch:
   - `git checkout cursor/-bc-831ea3ed-7836-4c29-9827-ecb063ed9331-6179`
   - `git pull origin cursor/-bc-831ea3ed-7836-4c29-9827-ecb063ed9331-6179`
4. Rebuild and restart stack:
   - `docker compose up -d --build`
5. Validate API health:
   - `curl -fsS http://127.0.0.1:8000/health`

## Runtime notes
- API service became healthy immediately after deploy.
- Worker healthcheck in deployed compose remained inherited legacy curl-based probe (checks `localhost:8000` inside worker) and reported `unhealthy`.
- Applied runtime-only fix on server with `docker-compose.override.yml` for worker healthcheck:
  - `celery -A app.workers.celery_app inspect ping | grep -q pong`
- Recreated worker container with override and validated healthy status.

## Result
- deploy status: `passed`
- stack status after runtime override:
  - `fitness-app-api-1`: healthy
  - `fitness-app-redis-1`: healthy
  - `fitness-app-worker-1`: healthy
- health endpoint response:
  - `{"status":"ok"}`

