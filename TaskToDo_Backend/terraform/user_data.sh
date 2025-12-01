#!/bin/bash
set -eux

# =============================================================================
# EC2 Instance Bootstrap Script for TaskToDo Backend
# This script runs on first boot via ASG Launch Template
# =============================================================================

# Update and install Docker
apt-get update -y
apt-get install -y docker.io docker-compose curl

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Create app directory
mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

# Create docker-compose file with injected variables
cat > docker-compose.yml <<'COMPOSE'
version: "3.8"

services:
  backend:
    image: ${docker_image}:latest
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      MONGODB_URI: "${mongodb_uri}"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
COMPOSE

# Pull and start the container
docker-compose pull
docker-compose up -d

# Set ownership
chown -R ubuntu:ubuntu /home/ubuntu/app

# Signal instance is ready
echo "Instance bootstrap complete at $(date)" > /home/ubuntu/ready.txt
