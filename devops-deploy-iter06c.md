# DevOps Deploy Report — iter-06c

## Credentials handling
- deployment executed with same server credentials as previous cycle (password auth).
- credentials used only in ephemeral runtime during SSH session.
- secrets were not persisted in repository files or process artifacts.
- local environment cleanup executed after deployment checks.

## Target
- host: `95.81.124.133`
- user: `root`
- app path: `/opt/fitness-app`
- deployed branch: `cursor/-bc-831ea3ed-7836-4c29-9827-ecb063ed9331-6179`

## Deployment actions
1. Update remote repository:
   - `git fetch origin cursor/-bc-831ea3ed-7836-4c29-9827-ecb063ed9331-6179`
   - `git checkout cursor/-bc-831ea3ed-7836-4c29-9827-ecb063ed9331-6179`
   - `git pull origin cursor/-bc-831ea3ed-7836-4c29-9827-ecb063ed9331-6179`
2. Rebuild/restart stack:
   - `docker compose up -d --build`
3. Prepare web release directory:
   - `mkdir -p /opt/fitness-app/web_build`
4. Upload and unpack web bundle:
   - upload `fitness_app-web-iter06c.tar.gz`
   - `tar -xzf fitness_app-web-iter06c.tar.gz`
5. Validate runtime:
   - `docker compose ps`
   - `curl -fsS http://127.0.0.1:8000/health`
   - worker health check via `docker inspect`

## Result
- deploy status: `passed`
- stack status:
  - `fitness-app-api-1`: healthy
  - `fitness-app-redis-1`: healthy
  - `fitness-app-worker-1`: healthy
- backend health endpoint:
  - `{"status":"ok"}`
- web artifact deployment:
  - `/opt/fitness-app/web_build/web/index.html` present (`web_ok`)

## Notes
- one transient network fetch failure occurred in first attempt; retry succeeded.
- deployment completed without rollback.
