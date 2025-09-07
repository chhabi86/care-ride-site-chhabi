#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")" && pwd)
echo "Deploy script running from $ROOT"

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo to install packages and manage services." >&2
  exit 1
fi

# Allow non-interactive runs by using the DOMAIN environment variable.
# If DOMAIN is not set and we have a TTY, prompt the user. Otherwise fail early.
if [ -z "${DOMAIN:-}" ]; then
  if [ -t 0 ]; then
    read -p "Enter domain for site (example.com): " DOMAIN
  else
    echo "Error: DOMAIN is not set and no TTY is attached. Provide DOMAIN as an environment variable or via the DEPLOY_DOMAIN secret." >&2
    exit 1
  fi
fi

apt update && apt upgrade -y
apt install -y git curl nginx certbot python3-certbot-nginx

# install docker
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi
if ! command -v docker-compose >/dev/null 2>&1; then
  apt install -y docker-compose
fi

cd $ROOT

if [ ! -d ".git" ]; then
  echo "Initializing git..."
  git init
  git remote add origin https://github.com/your/repo.git || true
fi

echo "Preparing environment file (backend.env)."
if [ -f backend.env.example ] && [ ! -f backend.env ]; then
  cp backend.env.example backend.env
  echo "Created backend.env from example — edit it with real secrets now (before next deploy)."
fi

echo "Building and starting containers (local docker-compose.yml)..."
docker compose -f docker-compose.yml build
docker compose -f docker-compose.yml up -d

echo "Configuring nginx for $DOMAIN"
NGINX_CONF="/etc/nginx/sites-available/care-ride"
cp nginx/care-ride.conf $NGINX_CONF
sed -i "s/server_name example.com www.example.com;/server_name $DOMAIN www.$DOMAIN;/" $NGINX_CONF
ln -sf $NGINX_CONF /etc/nginx/sites-enabled/care-ride
nginx -t && systemctl reload nginx

echo "Obtaining TLS certificate via certbot..."
certbot --nginx -d $DOMAIN -d www.$DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN || true

echo "Deployment complete. Visit https://$DOMAIN"
