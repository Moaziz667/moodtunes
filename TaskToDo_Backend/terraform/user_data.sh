#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -eux

# =============================================================================
# EC2 Instance Bootstrap Script for TaskToDo Backend
# This script runs on first boot via ASG Launch Template
# =============================================================================

echo "=== Starting bootstrap at $(date) ==="

# Update and install Docker
apt-get update -y
apt-get install -y docker.io docker-compose curl

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Wait for Docker to be ready
sleep 5
docker --version

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Create app directory
mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

echo "=== Creating docker-compose.yml ==="

# Create docker-compose file with injected variables
cat > docker-compose.yml <<COMPOSE
version: "3.8"

services:
  backend:
    image: ${docker_image}:latest
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      MONGODB_URI: "${mongodb_uri}"
COMPOSE

echo "=== docker-compose.yml content ==="
cat docker-compose.yml

echo "=== Pulling Docker image ==="
docker-compose pull

echo "=== Starting container ==="
docker-compose up -d

# Wait for container to start
sleep 10

echo "=== Container status ==="
docker ps -a

echo "=== Container logs ==="
docker-compose logs --tail=50

echo "=== Testing local endpoint ==="
curl -v http://localhost:3000/ || echo "Curl failed but continuing..."

# Set ownership
chown -R ubuntu:ubuntu /home/ubuntu/app

# Signal instance is ready
echo "=== Instance bootstrap complete at $(date) ===" | tee /home/ubuntu/ready.txt
