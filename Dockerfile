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

# Deployment stage - use build stage as base
FROM build AS deploy
WORKDIR /app

# Install wrangler globally (dependencies already available from build stage)
RUN yarn global add wrangler

# Set default command to wrangler deploy
CMD ["yarn", "wrangler", "deploy"]
