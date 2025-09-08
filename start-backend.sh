#!/bin/bash
echo "🚀 Starting CareRide Backend (Spring Boot + PostgreSQL)..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "⚠️  Docker Desktop is not running. Please start Docker Desktop first."
    exit 1
fi

# Start PostgreSQL database
echo "🗄️  Starting PostgreSQL database..."
docker-compose up -d db

echo "⏳ Waiting for database to be ready..."
sleep 10

# Start Spring Boot application
echo "🚀 Starting Spring Boot backend..."
if [ -f "./mvnw" ]; then
    ./mvnw spring-boot:run
else
    mvn spring-boot:run
fi
