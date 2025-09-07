# Care Ride Platform

Backend (Spring Boot) + Frontend (Angular) deployed via Docker Compose and proxied by host nginx.

## Quick Start (Local)
```bash
cd backend
cp backend.env.example backend.env  # once
docker compose up --build
# Browser: http://localhost (Angular) ; http://localhost/api/services (API)
```
Stop:
```bash
docker compose down
```

## Services
| Name | Port | Notes |
|------|------|-------|
| db | internal | Postgres 15 |
| backend | 8080 | Spring API (/api) |
| frontend | 8081 | Angular (proxied) |
| nginx (host) | 80/443 | Public entrypoint |

## Deploy (Remote)
Handled by GitHub Actions workflow -> SSH -> `deploy.sh`.
Requires secrets: DEPLOY_HOST, DEPLOY_USER, DEPLOY_SSH_PORT, DEPLOY_DOMAIN, DEPLOY_SSH_KEY (or *_B64).

Manual:
```bash
sudo DOMAIN=example.com ./deploy.sh
```

## Environment
Edit `backend.env` after copying from example; set secure DB password, mail creds, JWT secret.
Never commit real secrets.

## Logs
```bash
docker compose logs -f backend
docker compose logs -f frontend
```

## API Test
```bash
curl http://localhost/api/services
```

## Next Ideas
- Serve static frontend directly from nginx (remove frontend container)
- Add actuator health endpoint
- Proper JWT auth & security hardening

