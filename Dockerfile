# Build stage - install dependencies and build
FROM node:24-alpine AS build
WORKDIR /app

# Install dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy source code
COPY . .

# Build the application
ENV NODE_OPTIONS="--max-old-space-size=2048"
RUN yarn build

# Production stage - use build stage as base
FROM build AS production
WORKDIR /app

# Install serve globally
RUN yarn global add serve

# Copy built files (already available from build stage)
# No need to copy again as we're inheriting from build stage

EXPOSE 3000
CMD ["serve", "-s", "dist", "-l", "3000"]

# Development stage - run wrangler dev locally
FROM build AS worker
WORKDIR /app

# Expose Wrangler dev port
EXPOSE 8787

# Use npx to run local wrangler in dev mode
CMD ["npx", "wrangler", "dev", "--local", "--port", "8787"]
