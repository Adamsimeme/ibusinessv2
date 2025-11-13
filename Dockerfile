# iBusiness Backend - Production Docker Image
# Multi-stage build for optimized production image

# Stage 1: Builder
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++

# Copy package files
COPY backend/package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY backend/ ./

# Build the application (if needed)
# RUN npm run build

# Stage 2: Production
FROM node:18-alpine AS production

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create app user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S ibusiness -u 1001

# Set working directory
WORKDIR /app

# Copy package files
COPY backend/package*.json ./

# Copy dependencies from builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy application code
COPY backend/ ./

# Create necessary directories
RUN mkdir -p logs uploads && \
    chown -R ibusiness:nodejs /app

# Switch to non-root user
USER ibusiness

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/health', (res) => { \
    process.exit(res.statusCode === 200 ? 0 : 1) \
  }).on('error', () => process.exit(1))"

# Start the application with dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]
CMD ["npm", "start"]