#!/bin/bash

# Load environment variables from .env file if it exists
if [ -f .env ]; then
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

# Build deployment image
echo "🚀 Building deployment image..."
docker build --target deploy -t construction-supervision-tldraw:deploy .

# Deploy to Cloudflare (requires environment variables)
echo "☁️ Deploying to Cloudflare..."
docker run --rm \
  -e CLOUDFLARE_API_TOKEN="$CLOUDFLARE_API_TOKEN" \
  -e CLOUDFLARE_ACCOUNT_ID="$CLOUDFLARE_ACCOUNT_ID" \
  construction-supervision-tldraw:deploy

# Start production container
echo "🔄 Starting production container..."
cd ~/deploy
docker compose -f docker-compose-tldraw.yml down
docker compose -f docker-compose-tldraw.yml up -d

echo "✅ Deployment completed!"
