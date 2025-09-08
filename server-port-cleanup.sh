#!/bin/bash
# Run this script in your DigitalOcean console as root

echo "🔧 Cleaning up port 8080 conflicts..."

# Kill any processes using port 8080
echo "Killing processes on port 8080..."
fuser -k 8080/tcp 2>/dev/null || echo "No processes found on port 8080"

# Stop all Docker containers
echo "Stopping all Docker containers..."
docker stop $(docker ps -aq) 2>/dev/null || echo "No containers to stop"

# Remove all containers
echo "Removing all containers..."
docker rm $(docker ps -aq) 2>/dev/null || echo "No containers to remove"

# Clean up Docker networks
echo "Cleaning Docker networks..."
docker network prune -f

# Clean up unused Docker images
echo "Cleaning unused Docker images..."
docker image prune -f

# Verify port 8080 is free
echo "Verifying port 8080 is free..."
if netstat -tulpn | grep :8080; then
    echo "❌ Port 8080 still in use!"
    netstat -tulpn | grep :8080
else
    echo "✅ Port 8080 is now free!"
fi

echo "🎉 Server cleanup completed!"
