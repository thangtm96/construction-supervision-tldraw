#!/bin/bash

# Load environment variables from .env file if it exists
if [ -f .env_tldraw ]; then
    echo "📄 Loading environment variables from .env file..."
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "⚠️  .env file not found. Make sure environment variables are set manually."
fi

echo "🚀 Building and deploying with Docker..."

# Build the application
echo "📦 Building application..."
docker build --target build -t construction-supervision-tldraw:build .

# Build production image
echo "🏗️ Building production image..."
docker build --target production -t construction-supervision-tldraw:prod .

# Build worker image
echo "🚀 Building worker image..."
docker build --target worker -t construction-supervision-tldraw:worker .

# Start production container
echo "🔄 Starting production container..."
cd ~/deploy
docker compose -f docker-compose-tldraw.yml down
docker compose -f docker-compose-tldraw.yml up -d

echo "✅ Deployment completed!"
