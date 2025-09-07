# Deployment Normalization

This repository's root *is* the backend module. Use the `docker-compose.yml` located here.

Steps performed by deploy.sh:
1. Ensure DOMAIN provided (for nginx/certbot) if run from higher-level automation.
2. Install required packages + Docker.
3. Create `backend.env` from `backend.env.example` if missing.
4. `docker compose -f docker-compose.yml up -d` to start db + backend + (optional) pgadmin.

Do NOT rely on a parent directory `docker-compose.yml`; remove any server copy left from earlier attempts.
