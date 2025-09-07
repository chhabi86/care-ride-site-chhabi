# Deployment Overview

Repository root = backend module. A sibling directory `../frontend` (Angular) is built and run as a container, then proxied by nginx.

## Components
| Service | Port (host) | Purpose |
|---------|-------------|---------|
| db (Postgres 15) | internal only | Persistence |
| backend (Spring Boot) | 8080 | REST API under /api |
| frontend (Angular built, nginx) | 8081 | Serves SPA, proxied to root path / |
| nginx (host service) | 80/443 | Public entrypoint: proxies /api -> backend, / -> frontend |

## deploy.sh Steps
1. Require `DOMAIN` (for nginx + optional certbot TLS).  
2. Update/Install packages + Docker.  
3. Create `backend.env` if absent (copy from example).  
4. `docker compose build` backend + frontend images.  
5. Bring up db, backend, frontend (pgAdmin optional via `PROFILE_PGADMIN=1`).  
6. Install / refresh nginx site config (`nginx/care-ride.conf`).  
7. (Attempt) issue/renew TLS cert via certbot.  

## Environment Files
`backend.env.example` -> copy to `backend.env` and edit with production secrets (DB creds, mail, JWT secret). Never commit real secrets.  
`.env` holds `COMPOSE_PROJECT_NAME` only.

## Frontend
Dockerfile for Angular lives in `frontend/Dockerfile.prod`. The compose file references it with `context: ../frontend`.
The container exposes its nginx on 80; mapped to host 8081 to avoid clashing with system nginx.

## Nginx
`nginx/care-ride.conf` defines upstreams:
```
upstream backend_api { server 127.0.0.1:8080; }
upstream frontend_app { server 127.0.0.1:8081; }
```
Root path `/` -> `frontend_app`; `/api/` -> `backend_api`.

## Optional pgAdmin
Enable by exporting `PROFILE_PGADMIN=1` before running `deploy.sh` (will attach override file if port free).

## First-Time Manual Run (local dev)
```bash
cd backend
cp backend.env.example backend.env
docker compose up --build
# Visit: http://localhost (frontend) and http://localhost/api/services (proxied API)
```

## CI/CD
GitHub Actions workflow `.github/workflows/remote-deploy.yml` handles remote update via SSH + `deploy.sh`.

## Troubleshooting
```bash
docker compose ps
docker compose logs backend --tail=100
docker compose logs frontend --tail=100
sudo nginx -t
```

Common issues:
- 502 from nginx: one of upstream containers not yet ready or crashed.
- Connection refused on /api: backend container exited (check DB credentials in `backend.env`).

## Future Improvements
- Serve built static files directly from host nginx (remove frontend container) to reduce memory.
- Add health checks & monitoring.
- Harden nginx security headers & rate limiting.

