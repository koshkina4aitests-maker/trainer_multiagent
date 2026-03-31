# DevOps Web Publish Report — iter-06c (port exposure)

## Goal
- publish Flutter web bundle as a reachable frontend endpoint on a dedicated port.

## Actions
1. Created remote compose overlay:
   - file: `/opt/fitness-app/docker-compose.web.yml`
   - service: `web`
   - image: `nginx:1.27-alpine`
   - static mount: `/opt/fitness-app/web_build/web:/usr/share/nginx/html:ro`
   - published port: `8080:80`
2. Started web service:
   - `docker compose -f docker-compose.yml -f docker-compose.web.yml up -d web`
3. Verified local service response:
   - `curl http://127.0.0.1:8080` returns app `index.html`
4. Verified external reachability:
   - `http://95.81.124.133:8080` returns HTTP `200`

## Result
- web frontend is live on:
  - `http://95.81.124.133:8080`
- backend remains live on:
  - `http://95.81.124.133:8000`
