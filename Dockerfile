# Build stage - install dependencies and build
FROM node:24 AS build
WORKDIR /app

# Install dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy source code
COPY . .

# Build the application
ENV NODE_OPTIONS="--max-old-space-size=2048"
RUN yarn build

# Worker (dev) stage - reuse build artifacts and node_modules
FROM build AS worker
WORKDIR /app

# Expose Wrangler dev port
EXPOSE 8787

# Run Wrangler dev locally
CMD ["npx", "wrangler", "dev", "--local", "--port", "8787"]

# Production stage - small runtime image, only static assets
FROM node:24-alpine AS production
WORKDIR /app

# Install serve globally
RUN yarn global add serve

# Copy built files only
COPY --from=build /app/dist ./dist

EXPOSE 3000
CMD ["serve", "-s", "dist", "-l", "3000"]
