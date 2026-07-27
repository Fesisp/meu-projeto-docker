# Multi-stage Dockerfile for Node.js app
# Stage 1: Builder
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency manifests first to leverage Docker layer caching
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Stage 2: Final runtime image
FROM node:20-alpine AS runner

WORKDIR /app

# Copy dependencies and source from builder stage
COPY --from=builder /app /app

# Set non-root user for security
USER node

# Expose app port
EXPOSE 3000

# Environment variables default
ENV PORT=3000

# Start command
CMD ["node", "src/index.js"]
